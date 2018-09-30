module Main exposing (..)

import App.Update exposing (init, subscriptions, update)
import App.View exposing (view)
import Html


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
