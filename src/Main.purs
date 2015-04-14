module Main where

import Debug.Trace
import Control.Monad.Eff
import Control.Monad.Aff
import Network.Wai
import Network.Wai.Internal
import Network.HTTP
import Data.Maybe
import Network.Wai.Handler.Swai

body :: forall e. Request e -> Wai e String
body request = go ""
    where
        go s = do
            ns <- request.body
            case ns of
                 Just s' -> go (s ++ s')
                 Nothing -> return s

foreign import log """
function log(x) { return function() { console.log(x); } };
""" :: forall e a. a -> Eff (trace :: Trace | e) Unit

stringApplication :: forall e. Application (trace :: Trace | e)
stringApplication request respond = do
    liftEff' $ log request

    message <- case request.method of
                    POST -> body request
                    _    -> return $ "Not a Post"

    respond $ ResponseString 200
                             [contentType "text/plain", customString "x-my-header" "test"]
                             ("Echo: " ++ message)

main :: forall e. WaiEff (trace :: Trace | e)
main = do
    trace "running purescript-wai on port 3001..."
    run 3001 stringApplication





