module App.View exposing (view)

import App.Update exposing (Msg(Magnets))
import Html exposing (Html, div)
import Magnets.Model exposing (Model)
import Magnets.View


view : Model -> Html Msg
view model =
    div [] [ viewMainContent model ]


viewMainContent : Model -> Html Msg
viewMainContent model =
    Html.map Magnets (Magnets.View.view model)
