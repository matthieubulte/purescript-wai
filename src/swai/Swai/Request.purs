module Network.Wai.Handler.Swai.Request (makeRequest) where

import Data.Function
import Data.Maybe
import Control.Monad.Aff
import Control.Monad.Aff.AVar
import Network.HTTP
import Network.Wai.Internal
import Network.Wai
import Network.Wai.Handler.Swai.Types

makeRequest :: forall e. NodeRequest -> Wai e (Request e)
makeRequest request = do
    queue <- makeVar
    forkAff $ onData request queue

    let method = case (string2Verb $ nodeRequestMethod request) of
                    (Just m) -> m
                    Nothing  -> GET -- TODO: proper error handling here

    return { method         : method
           , rawPathInfo    : nodeRequestRawPathInfo request
           , rawQueryString : nodeRequestRawQueryString request
           , pathInfo       : nodeRequestPathInfo request
           , queryString    : nodeRequestQueryString request
           , headers        : nodeRequestHeaders request
           , body           : takeVar queue
           }

onData :: forall e. NodeRequest -> AVar (Maybe String) -> Wai e Unit
onData request queue = _onData >>= (putVar queue)
    where
        _onData :: Wai e (Maybe String)
        _onData = makeAff $ \_ success -> runFn4 onData' Just Nothing request success -- TODO: implement error handling

foreign import onData' """
function onData$prime(Just, Nothing, request, success) {
    return function() {
        request.on('data', function(data) {
            success(new Just(data))();
        });

        request.on('end', function() {
            success(Nothing)();
        });
    };
}""" :: forall e. Fn4 (String -> Maybe String) (Maybe String) NodeRequest (Maybe String -> WaiEff e) (WaiEff e)

foreign import nodeRequestMethod """
function nodeRequestMethod(request) {
    return request.method;
}
""" :: NodeRequest -> String

foreign import nodeRequestPathInfo """
function nodeRequestPathInfo(request) {
    var pathname = request.parsedUrl.pathname.substring(1);
    return pathname ? [] : pathname.split("/");
}
""" :: NodeRequest -> [String]

foreign import nodeRequestQueryString """
function nodeRequestQueryString(request) {
    return request.parsedUrl.query;
}
""" :: NodeRequest -> QueryString

foreign import nodeRequestRawPathInfo """
function nodeRequestRawPathInfo(request) {
    return request.parsedUrl.pathinfo;
}
""" :: NodeRequest -> String

foreign import nodeRequestRawQueryString """
function nodeRequestRawQueryString(request) {
    return request.search || "";
}
""" :: NodeRequest -> String

foreign import nodeRequestHeaders """
function nodeRequestHeaders(request) {
    return request.headers;
}
""" :: NodeRequest -> RequestHeaders
