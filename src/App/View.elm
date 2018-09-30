module App.View exposing (view)

import App.Model exposing (Model)
import App.Update exposing (Msg(Magnets))
import Html exposing (Html, div)
import Magnet.View


view : Model -> Html Msg
view model =
    div [] [ viewMainContent model ]


viewMainContent : Model -> Html Msg
viewMainContent model =
    Html.map Magnets (Magnet.View.view model)
