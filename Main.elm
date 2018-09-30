module Main exposing (main)

import App.Model exposing (Model)
import App.Update exposing (init, subscriptions, update)
import App.View exposing (view)
import Html


main : Program Never Model App.Update.Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
