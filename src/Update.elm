module Update exposing (Msg(..), subscriptions, update)

import Dict exposing (insert, remove)
import Draggable
import Draggable.Events exposing (onDragBy, onDragEnd)
import Json exposing (getMessage)
import Model
    exposing
        ( Drag
        , IncomingMessage(AllMagnets, SingleMove)
        , Magnet
        , Model
        , Position
        , serverUrl
        )
import Utils exposing (applyDrag, relativeCenter, updateMagnetMove)
import WebSocket


type Msg
    = IncomingMessage String
    | DragMsg (Draggable.Msg ())
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
update msg ({ magnets, dragData } as model) =
    case msg of
        DragMsg dragMsg ->
            Draggable.update dragConfig dragMsg model

        StartDragging dragMsg ( magnet, touchPosition ) ->
            let
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

                model_ =
                    { model
                        | dragData = Just drag
                        , magnets = remove magnet.id magnets
                    }
            in
            Draggable.update dragConfig dragMsg model_

        OnDragBy delta ->
            case applyDrag dragData delta of
                Just ( newDrag, moveJson ) ->
                    { model | dragData = Just newDrag } ! [ WebSocket.send serverUrl moveJson ]

                Nothing ->
                    model ! []

        IncomingMessage string ->
            case getMessage string of
                Ok message ->
                    case message of
                        AllMagnets magnets_ ->
                            { model | magnets = magnets_ } ! []

                        SingleMove move ->
                            let
                                magnets_ =
                                    updateMagnetMove magnets move
                            in
                            { model | magnets = magnets_ } ! []

                Err _ ->
                    model ! []

        StopDragging ->
            let
                magnets_ =
                    case dragData of
                        Just { magnet } ->
                            insert magnet.id magnet magnets

                        _ ->
                            magnets
            in
            { model | dragData = Nothing, magnets = magnets_ } ! []



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions { drag } =
    Sub.batch
        [ WebSocket.listen serverUrl IncomingMessage
        , Draggable.subscriptions DragMsg drag
        ]
