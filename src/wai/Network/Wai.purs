module Network.Wai
    ( Application()
    , MiddleWare()
    , ResponseCallback()
    , ResponseReceived(..)
    , readHeader
    , readQueryItem
    ) where

import Network.Wai.Internal
import Data.Function
import Data.Maybe


type Application e = Request e -> ResponseCallback e -> Wai e ResponseReceived

data ResponseReceived = ResponseReceived

type ResponseCallback e = Response e -> Wai e ResponseReceived

type MiddleWare e f = Application e -> Application f

readHeader :: String -> RequestHeaders -> Maybe String
readHeader = readMap

readQueryItem :: String -> QueryString -> Maybe String
readQueryItem = readMap

foreign import readMapImpl """
function readMapImpl(Just, Nothing, key, map) {
    key = key.toLowerCase();

    if(key in map) {
        return new Just(map[key]);
    }
    return Nothing;
}
""" :: forall m a. Fn4 (a -> Maybe a) (Maybe a) String m (Maybe a)

readMap :: forall m a. String -> m -> Maybe a
readMap = runFn4 readMapImpl (Just) Nothing

