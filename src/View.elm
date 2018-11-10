module View exposing (view)

import Dict exposing (values)
import Draggable
import Html exposing (Html, div, input, node, text)
import Html.Attributes exposing (class, href, rel, style, value)
import Html.Events exposing (onInput)
import Json exposing (decodeMouseOffsetWithMagnet)
import Model exposing (Magnet, Model)
import Update exposing (Msg(NewText, StartDragging))
import Utils exposing (getRectangleVertices, height, width)


view : Model -> Html Msg
view { magnets, dragData, newMagnetText } =
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
        , viewNewWordForm newMagnetText

        --        , div [] (List.map viewVertices magnets_)
        ]


viewMagnet : Magnet -> Html Msg
viewMagnet ({ position, rotation, word, locked } as magnet) =
    let
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


viewVertices : Magnet -> Html Msg
viewVertices magnet =
    div [] (List.map viewPoint <| getRectangleVertices magnet)


viewPoint : ( Float, Float ) -> Html Msg
viewPoint ( x, y ) =
    div
        [ style
            [ ( "left", px <| floor x )
            , ( "top", px <| floor y )
            , ( "width", px 1 )
            , ( "height", px 1 )
            , ( "background-color", "red" )
            , ( "position", "absolute" )
            ]
        ]
        []


viewNewWordForm : String -> Html Msg
viewNewWordForm newMagnetText =
    div
        [ style
            [ ( "bottom", px 30 )
            , ( "left", "calc(50% - 100px)" )
            , ( "position", "fixed" )
            , ( "width", px 100 )
            , ( "height", px height )
            ]
        ]
        [ input
            [ onInput NewText
            , class "box"
            , style
                [ ( "padding", "10px 20px" )
                , ( "cursor", "text" )
                ]
            , value newMagnetText
            ]
            []
        ]


px : Int -> String
px number =
    toString number ++ "px"
