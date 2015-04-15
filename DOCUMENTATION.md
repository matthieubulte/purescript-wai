# Module Documentation

## Module Main

#### `body`

``` purescript
body :: forall e. Request e -> Wai e String
```


#### `echoApplication`

``` purescript
echoApplication :: forall e. Application e
```


#### `countApplication`

``` purescript
countApplication :: forall e. AVar Number -> Application (trace :: Trace | e)
```


#### `main`

``` purescript
main :: forall e. WaiEff (trace :: Trace | e)
```



## Module Network.Wai.Handler.Swai

#### `run`

``` purescript
run :: forall e. Number -> Application e -> WaiEff e
```



## Module Network.Wai.Handler.Swai.Request

#### `makeRequest`

``` purescript
makeRequest :: forall e. NodeRequest -> Wai e (Request e)
```



## Module Network.Wai.Handler.Swai.Response

#### `makeResponseCallback`

``` purescript
makeResponseCallback :: forall e. NodeResponse -> ResponseCallback e
```



## Module Network.Wai.Handler.Swai.Types

#### `NodeRequest`

``` purescript
data NodeRequest :: *
```


#### `NodeResponse`

``` purescript
data NodeResponse :: *
```


#### `SwaiError`

``` purescript
data SwaiError
  = InvalidMethod 
```


#### `invalidMethod`

``` purescript
invalidMethod :: Error
```


#### `string2Error`

``` purescript
string2Error :: String -> Maybe SwaiError
```


#### `showSwaiError`

``` purescript
instance showSwaiError :: Show SwaiError
```



## Module Network.Wai

#### `Application`

``` purescript
type Application e = Request e -> ResponseCallback e -> Wai e ResponseReceived
```


#### `ResponseReceived`

``` purescript
data ResponseReceived
  = ResponseReceived 
```


#### `ResponseCallback`

``` purescript
type ResponseCallback e = Response e -> Wai e ResponseReceived
```


#### `MiddleWare`

``` purescript
type MiddleWare e f = Application e -> Application f
```


#### `readHeader`

``` purescript
readHeader :: String -> RequestHeaders -> Maybe String
```


#### `readQueryItem`

``` purescript
readQueryItem :: String -> QueryString -> Maybe String
```



## Module Network.Wai.Internal

#### `WAI`

``` purescript
data WAI :: !
```


#### `Wai`

``` purescript
type Wai e a = Aff (avar :: AVAR, wai :: WAI | e) a
```


#### `WaiEff`

``` purescript
type WaiEff e = Eff (avar :: AVAR, wai :: WAI | e) Unit
```


#### `QueryString`

``` purescript
data QueryString :: *
```


#### `RequestHeaders`

``` purescript
data RequestHeaders :: *
```


#### `Request`

``` purescript
type Request e = { body :: Wai e (Maybe String), headers :: RequestHeaders, queryString :: QueryString, pathInfo :: [String], rawQueryString :: String, rawPathInfo :: String, method :: Verb }
```


#### `ResponseHeaders`

``` purescript
type ResponseHeaders = [Header]
```


#### `Response`

``` purescript
data Response e
  = ResponseString StatusCode ResponseHeaders String
  | ResponseStream StatusCode ResponseHeaders (StreamingBody e)
```


#### `StreamingBody`

``` purescript
type StreamingBody e = (String -> Wai e Unit) -> Wai e Unit -> Wai e Unit
```




