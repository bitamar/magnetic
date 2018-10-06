module App.View exposing (view)

import App.Json exposing (decodeMouseOffsetWithMagnet)
import App.Model exposing (Magnet, Model)
import App.Update exposing (Msg(StartDragging))
import App.Utils exposing (height, width)
import Dict
import Draggable
import Html exposing (Html, div, node, text)
import Html.Attributes exposing (class, href, rel, style)


view : Model -> Html Msg
view model =
    let
        magnets =
            List.map viewMagnet <| Dict.values model.magnets
    in
    div []
        [ node "link" [ rel "stylesheet", href "magnet.css" ] []
        , div [ class "magnets" ] magnets
        ]


viewMagnet : Magnet -> Html Msg
viewMagnet ({ position, rotation, word } as magnet) =
    let
        px number =
            toString number ++ "px"

        styles =
            [ ( "width", px <| width magnet )
            , ( "height", px height )
            , -- Treat the magnet position as its center.
              ( "left", px <| position.x )
            , ( "top", px <| position.y )
            , ( "transform", "rotate(" ++ toString rotation ++ "deg)" )
            ]

        -- Using customerMouseTrigger, because I wasn't able to retrieve the
        -- current mouse position through mouseTrigger.
        dragStarter =
            Draggable.customMouseTrigger (decodeMouseOffsetWithMagnet magnet) StartDragging
    in
    div [ dragStarter, style styles ] [ text word ]
