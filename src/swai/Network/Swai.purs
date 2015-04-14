module Network.Wai.Handler.Swai (run) where

import Data.Function
import Control.Monad.Aff
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
    request' <- makeRequest request
    application request' (makeResponseCallback response) -- todo here we want to catch errors and repond 500

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
