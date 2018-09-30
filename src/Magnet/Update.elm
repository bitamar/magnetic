module Magnet.Update exposing (Msg(..), update)

import App.Model exposing (Magnets, Model)
import Dict
import Magnet.Model exposing (Magnet)
import Magnet.Utils exposing (setDragAt, setDragEnd, setDragStart)
import Mouse exposing (Position)


type Msg
    = DragStart Magnet Position
    | MouseMove Position
    | MouseUp Position


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    let
        magnets =
            model.magnets

        magnets_ =
            case msg of
                MouseMove position ->
                    case getDraggedMagnet magnets of
                        Nothing ->
                            magnets

                        Just magnet ->
                            updateMagnet magnets <| setDragAt magnet position

                MouseUp _ ->
                    case getDraggedMagnet magnets of
                        Nothing ->
                            magnets

                        Just magnet ->
                            updateMagnet magnets <| setDragEnd magnet

                DragStart magnet position ->
                    let
                        magnet_ =
                            setDragStart magnet position
                    in
                    updateMagnet magnets magnet_

        dragging =
            case msg of
                MouseUp _ ->
                    False

                MouseMove _ ->
                    model.dragging

                DragStart _ _ ->
                    True
    in
    ( { model | magnets = magnets_, dragging = dragging }, Cmd.none )


{-| Replace the updated magnet on the magnets dictionary.
-}
updateMagnet : Magnets -> Magnet -> Magnets
updateMagnet magnets magnet =
    Dict.update magnet.id (\_ -> Just magnet) magnets


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
