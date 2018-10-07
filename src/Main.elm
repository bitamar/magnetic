module Main exposing (main)

import Html
import Model exposing (Model)
import Update exposing (init, subscriptions, update)
import View exposing (view)


main : Program Never Model Update.Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
