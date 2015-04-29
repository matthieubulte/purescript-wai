module Main where

import Data.Maybe
import Debug.Trace
import Control.Monad.Eff
import Control.Monad.Aff
import Control.Monad.Aff.AVar
import Network.Wai
import Network.Wai.Internal
import Network.HTTP
import Network.Wai.Handler.Swai

body :: forall e. Request e -> Wai e String
body request = go ""
    where
        go message = do
            maybeRest <- request.body
            case maybeRest of
                 Just rest -> go (message ++ rest)
                 Nothing -> return message

file :: forall e. Application e
file request respond = respond $ ResponseFile status200 [contentType "text/html"] "./src/index.html"

echoApplication :: forall e. Application e
echoApplication request respond = do
    message <- body request
    respond $ ResponseString status200 [] message


countApplication :: forall e. AVar Number -> Application (trace :: Trace | e)
countApplication count request respond = do
    c <- takeVar count
    putVar count (c + 1)

    let message = "Request n°" ++ (show c)

    liftEff' $ trace message
    respond $ ResponseString status200 [] (show c)


main :: forall e. WaiEff (trace :: Trace | e)
main = do
    trace "running purescript-wai on port 3001..."
    run 3001 file





