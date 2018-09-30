module Magnets.Update exposing (Msg(..), update)

import Dict
import Magnet.Model exposing (Magnet)
import Magnet.Utils exposing (setDragAt, setDragEnd, setDragStart)
import Magnets.Model exposing (Model)
import Mouse exposing (Position)


type Msg
    = DragStart Magnet Position
    | MouseMove Position
    | MouseUp Position


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        MouseMove position ->
            let
                model_ =
                    case getDraggedMagnet model of
                        Nothing ->
                            model

                        Just magnet_ ->
                            updateMagnet model <| setDragAt magnet_ position
            in
            ( model_, Cmd.none )

        MouseUp _ ->
            let
                model_ =
                    case getDraggedMagnet model of
                        Nothing ->
                            model

                        Just magnet_ ->
                            updateMagnet model <| setDragEnd magnet_
            in
            ( model_, Cmd.none )

        DragStart magnet position ->
            let
                magnet_ =
                    setDragStart magnet position

                model_ =
                    updateMagnet model magnet_
            in
            ( model_, Cmd.none )


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
