module App.View exposing (..)

import App.Update exposing (..)
import Html exposing (..)
import Magnets.Model exposing (..)
import Magnets.View exposing (..)


view : Model -> Html Msg
view model =
    div [] [ viewMainContent model ]


viewMainContent : Model -> Html Msg
viewMainContent model =
    Html.map Magnets (Magnets.View.view model)
