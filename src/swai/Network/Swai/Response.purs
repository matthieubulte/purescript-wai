module Network.Wai.Handler.Swai.Response (makeResponseCallback) where

import Data.Function
import Control.Monad.Aff
import Network.HTTP
import Network.Wai.Internal
import Network.Wai
import Network.Wai.Handler.Swai.Types

foreign import fs "var fs = require('fs');" :: Unit

makeResponseCallback :: forall e. NodeResponse -> ResponseCallback e

makeResponseCallback response (ResponseString status headers body) = do
    liftEff' $ runFn4 respondString response (status2Number status) (headerToH <$> headers) body
    return ResponseReceived

makeResponseCallback response (ResponseFile status headers filename) = do
    liftEff' $ runFn4 respondFile response (status2Number status) (headerToH <$> headers) filename
    return ResponseReceived

data H = H String String

headerToH :: Header -> H
headerToH (Header head value) = H (show head) value

foreign import respondString """
function respondString(response, status, headers, body) {
    return function() {
        response.statusCode = status;
        headers.forEach(function(header) {
            response.setHeader(header.value0, header.value1);
        });
        response.end(body);
    };
}""" :: forall e. Fn4 NodeResponse Number [H] String (WaiEff e)

foreign import respondFile """
function respondFile(response, status, header, filepath) {
    return function() {
        fs.readFile(filepath, function(error, content) {
            if(error) {
                response.writeHead(404);
                response.end("404 - Not Found");
            } else {
                response.statusCode = status;
                headers.forEach(function(header) {
                    response.setHeader(header.value0, header.value1);
                });
                response.end(content);
            }
        });
    };
}""" :: forall e. Fn4 NodeResponse Number [H] String (WaiEff e)
