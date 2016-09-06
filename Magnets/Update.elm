module Magnets.Update exposing (..)

import Dict exposing (values)
import Mouse exposing (Position)
import Magnet.Utils exposing (setDragAt, setDragStart, setDragEnd)
import Magnet.Model exposing (Magnet)
import Magnets.Model exposing (..)


type Msg
    = DragStart Magnet Position
    | MouseMove Position
    | MouseUp Position


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        MouseMove position ->
            let
                model' =
                    case getDraggedMagnet model of
                        Nothing ->
                            model

                        Just magnet' ->
                            updateMagnet model <| setDragAt magnet' position
            in
                ( model', Cmd.none )

        MouseUp position ->
            let
                model' =
                    case getDraggedMagnet model of
                        Nothing ->
                            model

                        Just magnet' ->
                            updateMagnet model <| setDragEnd magnet' position
            in
                ( model', Cmd.none )

        DragStart magnet position ->
            let
                magnet' =
                    setDragStart magnet position

                model' =
                    updateMagnet model magnet'
            in
                ( model', Cmd.none )


{-| Replace the updated magnet on the magnets dictionary.
-}
updateMagnet : Model -> Magnet -> Model
updateMagnet model magnet =
    Dict.update magnet.id (\_ -> Just magnet) model


getDraggedMagnet : Model -> Maybe Magnet
getDraggedMagnet model =
    let
        isMagnetDragged : Magnet -> Bool
        isMagnetDragged magnet =
            case magnet.drag of
                Just _ ->
                    True

                Nothing ->
                    False
    in
        List.head <| List.filter isMagnetDragged <| Dict.values model
