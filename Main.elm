module Main exposing (..)

import App.Update exposing (init, subscriptions, update)
import App.View exposing (view)
import Html.App


main : Program Never
main =
    Html.App.program
        { init = App.Update.init
        , view = App.View.view
        , update = App.Update.update
        , subscriptions = App.Update.subscriptions
        }
