module Main exposing (main)

import Html
import Model exposing (Model, emptyModel)
import Update exposing (subscriptions, update)
import View exposing (view)


main : Program Never Model Update.Msg
main =
    Html.program
        { init = emptyModel ! []
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
