module Network.Wai
    ( Application()
    , MiddleWare()
    , ResponseCallback()
    , ResponseReceived(..)
    , readHeader
    , readQueryItem
    ) where

import Network.Wai.Internal
import Data.Maybe
import Utils

type Application e = Request e -> ResponseCallback e -> Wai e ResponseReceived

data ResponseReceived = ResponseReceived

type ResponseCallback e = Response e -> Wai e ResponseReceived

type MiddleWare e f = Application e -> Application f

readHeader :: String -> RequestHeaders -> Maybe String
readHeader = readMap

readQueryItem :: String -> QueryString -> Maybe String
readQueryItem = readMap


