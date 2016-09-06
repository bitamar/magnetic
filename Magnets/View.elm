module Magnets.View exposing (..)

import Dict exposing (values)
import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events exposing (on)
import Json.Decode as Json exposing ((:=))
import Magnet.Model exposing (..)
import Magnets.Model exposing (..)
import Magnets.Update exposing (..)
import Magnet.Utils exposing (..)
import Mouse exposing (position)


view : Magnets.Model.Model -> Html Msg
view model =
    div []
        [ div [] <| List.map printMagnet <| Dict.values model
        ]


printMagnet : Magnet -> Html Msg
printMagnet magnet =
    let
        realPosition =
            getPosition magnet

        px : Int -> String
        px number =
            toString number ++ "px"
    in
        div
            [ on "mousedown" (Json.map (DragStart magnet) Mouse.position)
            , style
                [ ( "background-color", "#3C8D2F" )
                , ( "cursor", "move" )
                , ( "width", "100px" )
                , ( "height", "30px" )
                , ( "border-radius", "2px" )
                , ( "position", "absolute" )
                , ( "left", px realPosition.x )
                , ( "top", px realPosition.y )
                , ( "color", "white" )
                , ( "display", "flex" )
                , ( "align-items", "center" )
                , ( "justify-content", "center" )
                ]
            ]
            [ text magnet.word
            ]
