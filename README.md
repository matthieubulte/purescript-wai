# purescript-wai
WAI - Web Application Interface

An attempt to port [WAI](https://github.com/yesodweb/wai/) to purescript based on nodejs.

Two projects are in this repository at the moment (later it will be split):
+ Wai: the type interface and high-level functionnalities.
+ Swai: the implementation of Wai, just a thin wrapper aroung nodejs.

### ToDo
+ Document
+ Add Examples
+ Implement missing response types
+ Add better error handling

### Examples
#### Echo Server
```purescript
module Main where

import Debug.Trace
import Control.Monad.Eff
import Control.Monad.Aff
import Control.Monad.Aff.AVar
import Network.Wai
import Network.Wai.Internal
import Network.HTTP
import Data.Maybe
import Network.Wai.Handler.Swai

-- this function will read the whole body of a request
body :: forall e. Request e -> Wai e String
body request = go ""
    where
        go message = do
            maybeRest <- request.body
            case maybeRest of
                 Just rest -> go (message ++ rest)
                 Nothing -> return message


echoApplication :: forall e. Application e
echoApplication request respond = do
    message <- body request
    respond $ ResponseString status200 [] message

main :: forall e. WaiEff (trace :: Trace | e)
main = do
    trace "running purescript-wai on port 3001..."
    run 3001 echoApplication
```

#### Counting Requests
```purescript
module Main where

import Debug.Trace
import Control.Monad.Eff
import Control.Monad.Aff
import Control.Monad.Aff.AVar
import Network.HTTP
import Network.Wai
import Network.Wai.Internal
import Network.Wai.Handler.Swai

countApplication :: forall e. AVar Number -> Application (trace :: Trace | e)
countApplication count request respond = do
    -- read the current requests count
    c <- takeVar count

    -- update the mutable variable with the incremented request count
    putVar count (c + 1)

    let message = "Request n°" ++ (show c)

    -- here we can have some additional side effects like logging
    liftEff' $ trace message

    -- finally respond to the request with the request count
    respond $ ResponseString status200 [] (show c)


main :: forall e. WaiEff (trace :: Trace | e)
main = launchAff $ do
    -- create te mutable variable that will track the number of request
    count <- makeVar

    -- initialize this variable
    putVar count 0

    liftEff' $ do
        trace "running purescript-wai on port 3001..."

        -- pass the count mutable variable to the application so that it can be used by it
        run 3001 $ countApplication count
```
