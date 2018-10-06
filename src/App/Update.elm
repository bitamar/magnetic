module App.Update exposing (Msg(..), init, subscriptions, update)

import App.Json exposing (getMessage)
import App.Model
    exposing
        ( Drag
        , IncomingMessage(AllMagnets, SingleMove)
        , Magnet
        , Model
        , Position
        , emptyModel
        , serverUrl
        )
import App.Utils exposing (applyDrag, relativeCenter, updateMagnetMove)
import Draggable
import Draggable.Events exposing (onDragBy, onDragEnd)
import WebSocket


type Msg
    = IncomingMessage String
    | DragMsg (Draggable.Msg ())
    | OnDragBy Draggable.Delta
    | StopDragging
    | StartDragging (Draggable.Msg ()) ( Magnet, Position )


init : ( Model, Cmd Msg )
init =
    emptyModel ! []


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
                center =
                    relativeCenter magnet

                relativeHorizontalDistance =
                    toFloat (touchPosition.x - center.x) / toFloat center.x

                drag =
                    Drag magnet.id relativeHorizontalDistance
            in
            { model | dragData = Just drag }
                |> Draggable.update dragConfig dragMsg

        OnDragBy delta ->
            let
                ( magnets, maybeMoveJson ) =
                    applyDrag model.magnets model.dragData delta

                cmd =
                    case maybeMoveJson of
                        Just json ->
                            WebSocket.send serverUrl json

                        _ ->
                            Cmd.none
            in
            { model | magnets = magnets } ! [ cmd ]

        IncomingMessage string ->
            case getMessage string of
                Ok message ->
                    case message of
                        AllMagnets magnets ->
                            { model | magnets = magnets } ! []

                        SingleMove move ->
                            let
                                magnets_ =
                                    updateMagnetMove model.magnets move
                            in
                            { model | magnets = magnets_ } ! []

                Err _ ->
                    model ! []

        StopDragging ->
            { model | dragData = Nothing } ! []



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions { drag } =
    Sub.batch
        [ WebSocket.listen serverUrl IncomingMessage
        , Draggable.subscriptions DragMsg drag
        ]
