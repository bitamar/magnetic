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
            , ( "color", "white" )
            , ( "background-color", "#333" )
            , ( "border", "1px solid white" )
            , ( "display", "flex" )
            , ( "align-items", "center" )
            , ( "justify-content", "center" )
            , ( "cursor", "move" )
            , ( "width", "100px" )
            , ( "height", "30px" )
            , ( "border-radius", "2px" )
            , ( "position", "absolute" )
            , ( "-webkit-touch-callout", "none" )
            , ( "-webkit-user-select", "none" )
            , ( "-khtml-user-select", "none" )
            , ( "-moz-user-select", "none" )
            , ( "-ms-user-select", "none" )
            , ( "user-select", "none" )
            ]
        ]
        [ text magnet.word
        ]
