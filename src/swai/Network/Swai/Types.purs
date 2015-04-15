module Network.Wai.Handler.Swai.Types where

import Data.Maybe
import Control.Monad.Eff.Exception
import Control.Monad.Error.Class

foreign import data NodeRequest  :: *
foreign import data NodeResponse :: *

data SwaiError = InvalidMethod

invalidMethod :: Error
invalidMethod = error $ show InvalidMethod

string2Error :: String -> Maybe SwaiError
string2Error "InvalidMethod" = Just InvalidMethod
string2Error _               = Nothing

instance showSwaiError :: Show SwaiError where
    show InvalidMethod = "InvalidMethod"
