-- This file is part of the Wire Server implementation.
--
-- Copyright (C) 2021 Wire Swiss GmbH <opensource@wire.com>
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
module Test.Wire.API.Golden.Generated.MemberUpdate_user where

import Imports (Bool (False, True), Maybe (Just, Nothing), fromJust, ($), (.))
import Wire.API.Conversation (MemberUpdate (..))
import Wire.API.Conversation.Member (MutedStatus (MutedStatus))
import Wire.API.Conversation.Role (parseRoleName)

testObject_MemberUpdate_user_1 :: MemberUpdate
testObject_MemberUpdate_user_1 =
  MemberUpdate
    { mupOtrMute = Just False,
      mupOtrMuteStatus = Just . MutedStatus $ 0,
      mupOtrMuteRef = Just "h\52974N",
      mupOtrArchive = Just True,
      mupOtrArchiveRef = Just "ref",
      mupHidden = Just False,
      mupHiddenRef = Just "",
      mupConvRoleName =
        Just
          ( fromJust
              ( parseRoleName
                  "nn8oubrrivojp29q65krhyfzzgvzt3yb18z_39zct19xff_7_wm4xk0ixmzaep5oj3cdajj36vwbc89pgajtmzo1rbwc40ulc837b1aknib6cj03k64ovt4p0h"
              )
          )
    }

testObject_MemberUpdate_user_2 :: MemberUpdate
testObject_MemberUpdate_user_2 =
  MemberUpdate
    { mupOtrMute = Nothing,
      mupOtrMuteStatus = Nothing,
      mupOtrMuteRef = Nothing,
      mupOtrArchive = Nothing,
      mupOtrArchiveRef = Nothing,
      mupHidden = Just False,
      mupHiddenRef = Nothing,
      mupConvRoleName = Nothing
    }
