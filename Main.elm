module Main exposing (main)

import App.Update exposing (init, subscriptions, update)
import App.View exposing (view)
import Html
import Magnets.Model exposing (Model)


main : Program Never Model App.Update.Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
