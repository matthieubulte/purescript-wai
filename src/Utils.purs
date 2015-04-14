module Utils where

import Data.Maybe
import Data.Function

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

foreign import unsafeGet """
function unsafeGet(key) {
    return function(o) {
        return o[key];;
    }
};
""":: forall a b. String -> a -> b

