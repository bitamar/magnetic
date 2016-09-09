module Magnets.View exposing (..)

import Dict exposing (values)
import Html exposing (..)
import Html.Attributes exposing (class, style)
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
        [ div [ class "magnets" ] <| List.map printMagnet <| Dict.values model
          -- , div [] [ text <| toString model ]
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
            , ( "transform", "rotate(" ++ (toString magnet.rotation) ++ "deg)" )
            ]
        ]
        [ text magnet.word
        ]
