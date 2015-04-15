module Network.Wai.Handler.Swai (run) where

import Data.Function
import Data.Maybe
import Control.Monad.Aff
import Control.Monad.Eff.Exception
import Control.Monad.Error.Class
import Network.HTTP
import Network.Wai.Internal
import Network.Wai
import Network.Wai.Handler.Swai.Types
import Network.Wai.Handler.Swai.Request
import Network.Wai.Handler.Swai.Response

foreign import url "var url = require('url');" :: Unit
foreign import http "var http = require('http');" :: Unit

data P = P NodeRequest NodeResponse

run :: forall e. Number -> Application e -> WaiEff e
run port application = launchAff $ do
    P request response <- serve port

    let respond = makeResponseCallback response
    catchError (handleRequest request respond) (handleError respond)

    where
        handleRequest request respond = do
            request' <- makeRequest request
            application request' respond

        handleError respond error = respond $ case (string2Error $ message error) of
                                                   (Just InvalidMethod) -> ResponseString status400 [] ""
                                                   Nothing              -> ResponseString status500 [] ""


-- Effect forking each new request into a new Aff thread
serve :: forall e. Number -> Wai e P
serve port = makeAff $ \_ success -> runFn3 serve' P port success

foreign import serve' """
function serve$prime(mkT, port, onRequest) {
    return function() {
        http.createServer(function(request, response) {
            request.setEncoding('utf8'); // TODO: let the user define this?
            request.parsedUrl = url.parse(request.url, true);

            onRequest(mkT(request)(response))();
        }).listen(port);
    };
}
""" :: forall e. Fn3 (NodeRequest -> NodeResponse -> P) Number (P -> WaiEff e) (WaiEff e)
