module Network.Wai.Handler.Swai.Types where

import Control.Monad.Eff.Exception
import Control.Monad.Error.Class

foreign import data NodeRequest  :: *
foreign import data NodeResponse :: *

data SwaiError = InvalidMethod

invalidMethod :: Error
invalidMethod = error $ show InvalidMethod

instance showSwaiError :: Show SwaiError where
    show InvalidMethod = "InvalidMethod"
