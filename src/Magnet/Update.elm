module Magnet.Update exposing (Msg(..), update)

import App.Model exposing (Magnets, Model, serverUrl)
import Dict
import Json.Decode exposing (decodeString)
import Json.Encode exposing (encode)
import Magnet.Model exposing (Magnet, Move)
import Magnet.Utils
    exposing
        ( decodeMove
        , encodeMove
        , getPosition
        , setDragAt
        , setDragEnd
        , setDragStart
        )
import Mouse exposing (Position)
import WebSocket


type Msg
    = DragStart Magnet Position
    | MouseMove Position
    | MouseUp Position
    | IncomingMove Move


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    let
        magnets =
            model.magnets
    in
    case msg of
        MouseMove position ->
            case getDraggedMagnet magnets of
                Nothing ->
                    model ! []

                Just magnet ->
                    let
                        magnet_ =
                            setDragAt magnet position

                        -- TODO: refactor setDragAt to also set the position, to avoid this mess.
                        magnet__ =
                            { magnet_ | position = getPosition magnet_ }

                        moveJson =
                            encode 0 <| encodeMove magnet__

                        magnets_ =
                            updateMagnet magnets magnet_
                    in
                    { model | magnets = magnets_ } ! [ WebSocket.send serverUrl moveJson ]

        MouseUp _ ->
            case getDraggedMagnet magnets of
                Nothing ->
                    model ! []

                Just magnet ->
                    let
                        magnets_ =
                            updateMagnet magnets <| setDragEnd magnet
                    in
                    { model | magnets = magnets_, dragging = False } ! []

        DragStart magnet position ->
            let
                magnet_ =
                    setDragStart magnet position

                magnets_ =
                    updateMagnet magnets magnet_
            in
            { model | magnets = magnets_, dragging = True } ! []

        IncomingMove move ->
            let
                magnets_ =
                    updateMagnetMove magnets move
            in
            { model | magnets = magnets_ } ! []


{-| Replace the updated magnet on the magnets dictionary.
-}
updateMagnet : Magnets -> Magnet -> Magnets
updateMagnet magnets magnet =
    Dict.update magnet.id (\_ -> Just magnet) magnets


{-| Apply a move to a magnet in the dictionary.
-}
updateMagnetMove : Magnets -> Move -> Magnets
updateMagnetMove magnets move =
    let
        position =
            { x = move.x, y = move.y }

        applyMove maybeMagnet =
            case maybeMagnet of
                Just magnet ->
                    Just { magnet | position = position, rotation = move.rotation }

                _ ->
                    Nothing
    in
    Dict.update move.id applyMove magnets


getDraggedMagnet : Magnets -> Maybe Magnet
getDraggedMagnet magnets =
    let
        isMagnetDragged : Magnet -> Bool
        isMagnetDragged magnet =
            case magnet.drag of
                Just _ ->
                    True

                Nothing ->
                    False
    in
    List.head <| List.filter isMagnetDragged <| Dict.values magnets
