module Magnet.View exposing (view)

import App.Model exposing (Model)
import Dict
import Html exposing (Html, div, text)
import Html.Attributes exposing (class, style)
import Html.Events exposing (on)
import Json.Decode as Json
import Magnet.Model exposing (Magnet)
import Magnet.Update exposing (Msg(DragStart))
import Magnet.Utils exposing (getPosition)
import Mouse


view : Model -> Html Msg
view model =
    div []
        [ div [ class "magnets" ] <| List.map printMagnet <| Dict.values model
        ]


px : Int -> String
px number =
    toString number ++ "px"


printMagnet : Magnet -> Html Msg
printMagnet magnet =
    div
        [ on "mousedown" (Json.map (DragStart magnet) Mouse.position)
        , style
            [ -- Treat the magnet position as its center.
              ( "left", px <| (getPosition magnet).x - 50 )
            , ( "top", px <| (getPosition magnet).y - 15 )
            , ( "transform", "rotate(" ++ toString magnet.rotation ++ "deg)" )
            ]
        ]
        [ text magnet.word
        ]
