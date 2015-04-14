module Network.Wai.Internal
    ( Wai ()
    , WaiEff()
    , WAI (..)
    , Request ()
    , Response (..)
    , StreamingBody (..)
    , QueryString (..)
    , RequestHeaders (..)
    , ResponseHeaders ()
    ) where

import Network.HTTP
import Control.Monad.Eff
import Control.Monad.Aff
import Control.Monad.Aff.AVar
import Data.Maybe

foreign import data WAI :: !

type Wai e a = Aff (wai :: WAI, avar :: AVAR | e) a
type WaiEff e = Eff (wai :: WAI, avar :: AVAR | e) Unit

foreign import data QueryString :: *
foreign import data RequestHeaders :: *

type Request e = { method         :: Verb
                 , rawPathInfo    :: String
                 , rawQueryString :: String
                 , pathInfo       :: [String]
                 , queryString    :: QueryString
                 , headers        :: RequestHeaders
                 , body           :: Wai e (Maybe String)
                 }

type ResponseHeaders = [Header]

data Response e = ResponseString Number ResponseHeaders String
                | ResponseStream Number ResponseHeaders (StreamingBody e)

type StreamingBody e = (String -> Wai e Unit) -> Wai e Unit -> Wai e Unit
