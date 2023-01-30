{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE NumericUnderscores #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE UndecidableInstances #-}

-- This file is part of the Wire Server implementation.
--
-- Copyright (C) 2022 Wire Swiss GmbH <opensource@wire.com>
--
-- This program is free software: you can redistribute it and/or modify it under
-- the terms of the GNU Affero General Public License as published by the Free
-- Software Foundation, either version 3 of the License, or (at your option) any
-- later version.
--
-- This program is distributed in the hope that it will be useful, but WITHOUT
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
-- details.
--
-- You should have received a copy of the GNU Affero General Public License along
-- with this program. If not, see <https://www.gnu.org/licenses/>.

module Util.Test.SQS where

import qualified Amazonka as AWS
import qualified Amazonka.SQS as SQS
import qualified Amazonka.SQS.Lens as SQS
import Control.Lens hiding ((.=))
import qualified Data.ByteString.Base64 as B64
import Data.List (delete)
import Data.ProtoLens
import qualified Data.Text.Encoding as Text
import Imports
import Safe (headDef)
import UnliftIO (Async, async)
import UnliftIO.Resource (MonadResource, ResourceT)
import UnliftIO.Timeout (timeout)

data SQSWatcher a = SQSWatcher
  { watcherProcess :: Async (),
    events :: IORef [a]
  }

-- | Starts an async loop which continuously retrieves messages from a given SQS
-- queue, parses them and stores them in an `IORef [a]`.
--
-- This function drops everything in the queue before starting the async loop.
-- This helps test run faster and makes sure that initial tests don't timeout if
-- the queue has too many things in it before the tests start.
watchSQSQueue :: Message a => AWS.Env -> Text -> IO (SQSWatcher a)
watchSQSQueue env queueUrl = do
  eventsRef <- newIORef []
  ensureEmpty
  process <- async $ recieveLoop eventsRef
  pure $ SQSWatcher process eventsRef
  where
    recieveLoop ref = do
      let rcvReq =
            SQS.newReceiveMessage queueUrl
              & set SQS.receiveMessage_waitTimeSeconds (Just 100)
                . set SQS.receiveMessage_maxNumberOfMessages (Just 1)
                . set SQS.receiveMessage_visibilityTimeout (Just 1)
      rcvRes <- execute env $ sendEnv rcvReq
      let msgs = fromMaybe [] $ view SQS.receiveMessageResponse_messages rcvRes
      parsedMsgs <- fmap catMaybes . execute env $ mapM (parseDeleteMessage queueUrl) msgs
      case parsedMsgs of
        [] -> pure ()
        _ -> atomicModifyIORef ref $ \xs ->
          (parsedMsgs <> xs, ())
      recieveLoop ref

    ensureEmpty :: IO ()
    ensureEmpty = do
      let rcvReq =
            SQS.newReceiveMessage queueUrl
              & set SQS.receiveMessage_waitTimeSeconds (Just 1)
                . set SQS.receiveMessage_maxNumberOfMessages (Just 10) -- 10 is maximum allowed by AWS
                . set SQS.receiveMessage_visibilityTimeout (Just 1)
      rcvRes <- execute env $ sendEnv rcvReq
      case fromMaybe [] $ view SQS.receiveMessageResponse_messages rcvRes of
        [] -> pure ()
        ms -> do
          execute env $ mapM_ (deleteMessage queueUrl) ms
          ensureEmpty

-- | Waits for a message matching a predicate for a given number of seconds.
waitForMessage :: (MonadUnliftIO m, Eq a, Show a) => SQSWatcher a -> Int -> (a -> Bool) -> m (Maybe a)
waitForMessage watcher seconds predicate = timeout (seconds * 1_000_000) poll
  where
    poll = do
      matched <- atomicModifyIORef (events watcher) $ \events ->
        case filter predicate events of
          [] -> (events, Nothing)
          (x : _) -> (delete x events, Just x)
      maybe (threadDelay 10000 >> poll) pure matched

-- | First waits for a message matching a given predicate for 3 seconds (this
-- number could be chosen more scientifically) and then uses a callback to make
-- an assertion on such a message.
assertMessage :: (Show a, MonadUnliftIO m, Eq a, HasCallStack) => SQSWatcher a -> String -> (a -> Bool) -> (String -> Maybe a -> m ()) -> m ()
assertMessage watcher label predicate callback = do
  matched <- waitForMessage watcher 3 predicate
  callback label matched

-----------------------------------------------------------------------------
-- Generic AWS execution helpers
execute ::
  AWS.Env ->
  ReaderT AWS.Env (ResourceT IO) a ->
  IO a
execute env = AWS.runResourceT . flip runReaderT env

-----------------------------------------------------------------------------
-- Internal. Most of these functions _can_ be used outside of this function
-- but probably do not need to
receive :: Int -> Text -> SQS.ReceiveMessage
receive n url =
  SQS.newReceiveMessage url
    & set SQS.receiveMessage_waitTimeSeconds (Just 1)
      . set SQS.receiveMessage_maxNumberOfMessages (Just n)
      . set SQS.receiveMessage_visibilityTimeout (Just 1)

fetchMessage :: (MonadIO m, Message a, MonadReader AWS.Env m, MonadResource m) => Text -> String -> (String -> Maybe a -> IO ()) -> m ()
fetchMessage url label callback = do
  msgs <- fromMaybe [] . view SQS.receiveMessageResponse_messages <$> sendEnv (receive 1 url)
  events <- mapM (parseDeleteMessage url) msgs
  liftIO $ callback label (headDef Nothing events)

deleteMessage :: (Monad m, MonadReader AWS.Env m, MonadResource m) => Text -> SQS.Message -> m ()
deleteMessage url m = do
  for_
    (m ^. SQS.message_receiptHandle)
    (void . sendEnv . SQS.newDeleteMessage url)

parseDeleteMessage :: (Monad m, Message a, MonadIO m, MonadReader AWS.Env m, MonadResource m) => Text -> SQS.Message -> m (Maybe a)
parseDeleteMessage url m = do
  let decodedMessage = decodeMessage <=< (B64.decode . Text.encodeUtf8)
  evt <- case decodedMessage <$> (m ^. SQS.message_body) of
    Just (Right e) -> pure (Just e)
    _ -> do
      liftIO $ print ("Failed to parse SQS message or event" :: String)
      pure Nothing
  deleteMessage url m
  pure evt

sendEnv :: (MonadReader AWS.Env m, MonadResource m, AWS.AWSRequest a) => a -> m (AWS.AWSResponse a)
sendEnv x = flip AWS.send x =<< ask
