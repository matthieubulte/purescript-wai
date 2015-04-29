module Main where

import Data.Maybe
import Debug.Trace
import Control.Apply
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

-- Application echo-ing the received content
echo :: forall e. Application e
echo request respond = do
    message <- body request
    respond $ ResponseString status200 [] message


-- Application counting the number of requests received
count :: forall e. Wai e (Application e)
count = do
    count <- makeVar
    putVar count 0

    return $ \request respond -> do
        c <- takeVar count
        putVar count (c + 1)
        respond $ ResponseString status200 [] (show c)


-- Application serving a static index.html file
file :: forall e. Application e
file request respond = case request.rawPathInfo of
  "/"     -> respond index
  _       -> respond notFound

index = ResponseFile
    status200
    [contentType "text/html"]
    "./src/example/index.html"

notFound = ResponseString
    status404
    [contentType "text/plain"]
    "404 - Not Found"

-- Composed application, serve dynamic pages and fallback to static pages
composed = do
    counter <- count
    return \request respond -> case request.rawPathInfo of
        "/count" -> counter request respond
        "/echo"  -> echo request respond
        _        -> file request respond

main = runAff
        (\_           -> trace "error while launching aplpication")
        (\application -> trace "starting on port 3001..." *> run 3001 application)
        composed
