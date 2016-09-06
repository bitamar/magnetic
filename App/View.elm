module App.View exposing (..)

import Html exposing (..)
import Html.App as Html
import App.Model exposing (..)
import App.Update exposing (..)
import Magnets.View exposing (..)


view : Model -> Html Msg
view model =
    div [] [ viewMainContent model ]


viewMainContent : Model -> Html Msg
viewMainContent model =
    Html.map Magnets (Magnets.View.view model.magnets)
