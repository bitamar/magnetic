module Update exposing (Msg(..), subscriptions, update)

import Dict exposing (remove)
import Draggable
import Draggable.Events exposing (onDragBy, onDragEnd)
import Json exposing (getMessage)
import Keyboard
import Model exposing (Drag, IncomingMessage(..), Magnet, Model, Position, serverUrl)
import Utils
    exposing
        ( applyDrag
        , applyIncomingMove
        , createMagnet
        , relativeCenter
        , stopDrag
        , updateMagnet
        )
import WebSocket


type Msg
    = DragMsg (Draggable.Msg ())
    | IncomingMessage String
    | KeyMsg Keyboard.KeyCode
    | NewText String
    | OnDragBy Draggable.Delta
    | StopDragging
    | StartDragging (Draggable.Msg ()) ( Magnet, Position )


dragConfig : Draggable.Config () Msg
dragConfig =
    Draggable.customConfig
        [ onDragBy OnDragBy
        , onDragEnd StopDragging
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DragMsg dragMsg ->
            Draggable.update dragConfig dragMsg model

        StartDragging dragMsg ( magnet, touchPosition ) ->
            let
                -- End the previous drag, because StartDragging may be called
                -- before the StopDragging of the previous drag.
                model_ =
                    stopDrag model

                center =
                    relativeCenter magnet

                relativeHorizontalDistance =
                    toFloat (touchPosition.x - center.x) / toFloat center.x

                -- Easing the rotation when grabbing close to the horizontal
                -- center by cubing the relative distance. Keeping its sign
                -- when it's negative by using abs once.
                rotationFactor =
                    abs relativeHorizontalDistance * relativeHorizontalDistance

                drag =
                    Drag magnet rotationFactor

                model__ =
                    { model_
                        | dragData = Just drag
                        , magnets = remove magnet.id model_.magnets
                    }
            in
            Draggable.update dragConfig dragMsg model__

        OnDragBy delta ->
            case model.dragData of
                Just drag ->
                    let
                        ( newDrag, cmd ) =
                            applyDrag model.magnets drag delta
                    in
                    { model | dragData = Just newDrag } ! [ cmd ]

                Nothing ->
                    model ! []

        IncomingMessage string ->
            case getMessage string of
                Ok message ->
                    case message of
                        AllMagnets magnets ->
                            { model | magnets = magnets } ! []

                        SingleMagnet magnet ->
                            { model | magnets = updateMagnet model.magnets magnet } ! []

                        SingleMove move ->
                            let
                                magnets_ =
                                    applyIncomingMove model.magnets move
                            in
                            { model | magnets = magnets_ } ! []

                        Unlock id ->
                            let
                                unlock =
                                    Maybe.map (\magnet -> { magnet | locked = False })

                                magnets_ =
                                    Dict.update id unlock model.magnets
                            in
                            { model | magnets = magnets_ } ! []

                Err error ->
                    let
                        _ =
                            Debug.log "error" error
                    in
                    model ! []

        KeyMsg code ->
            if code == 13 then
                createMagnet model

            else
                model ! []

        NewText text ->
            { model | newMagnetText = text } ! []

        StopDragging ->
            stopDrag model ! []



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions { drag } =
    Sub.batch
        [ WebSocket.listen serverUrl IncomingMessage
        , Draggable.subscriptions DragMsg drag
        , Keyboard.presses KeyMsg
        ]
