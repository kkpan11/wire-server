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
module Test.Wire.API.User.Auth where

import qualified Data.Aeson as Aeson
import Imports
import qualified Test.Tasty as T
import Test.Tasty.HUnit
import Wire.API.User
import Wire.API.User.Auth

tests :: T.TestTree
tests = T.testGroup "Auth" [loginIdHappyCase, loginIdFailFast]

loginIdHappyCase :: T.TestTree
loginIdHappyCase = testCase "LoginId parser: valid email" $ do
  let actual :: Maybe LoginId = Aeson.decode "{\"email\":\"foo@bar.com\"}"
  let expected = Just $ LoginByEmail (Email {emailLocal = "foo", emailDomain = "bar.com"})
  assertEqual "should succeed" expected actual

loginIdFailFast :: T.TestTree
loginIdFailFast = testCase "LoginId parser: invalid email, valid phone" $ do
  let actual :: Maybe LoginId = Aeson.decode "{\"email\":\"invalid-email\",\"phone\":\"+123456789\"}"
  let expected = Nothing
  assertEqual "should fail if any provided login id is invalid" expected actual
