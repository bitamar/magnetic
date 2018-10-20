module View exposing (view)

import Dict exposing (values)
import Draggable
import Html exposing (Html, div, node, text)
import Html.Attributes exposing (class, href, rel, style)
import Json exposing (decodeMouseOffsetWithMagnet)
import Model exposing (Magnet, Model)
import Update exposing (Msg(StartDragging))
import Utils exposing (height, width)


view : Model -> Html Msg
view { magnets, dragData } =
    let
        -- Append the dragged magnet to the list.
        magnets_ =
            case dragData of
                Just { magnet } ->
                    values magnets ++ [ magnet ]

                _ ->
                    values magnets
    in
    div []
        [ node "link" [ rel "stylesheet", href "magnet.css" ] []
        , div [ class "magnets" ] (List.map viewMagnet magnets_)
        ]


viewMagnet : Magnet -> Html Msg
viewMagnet ({ position, rotation, word, locked } as magnet) =
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

        attr =
            if not locked then
                -- Using customerMouseTrigger, because I wasn't able to retrieve the
                -- current mouse position through mouseTrigger.
                Draggable.customMouseTrigger (decodeMouseOffsetWithMagnet magnet) StartDragging

            else
                class "locked"
    in
    div [ attr, style styles ] [ text word ]
