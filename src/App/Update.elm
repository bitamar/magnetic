module App.Update exposing (Msg(..), init, subscriptions, update)

import App.Model
    exposing
        ( IncomingMessage(AllMagnets, SingleMove)
        , Model
        , emptyModel
        , serverUrl
        )
import Json.Decode exposing (decodeString)
import Magnet.Update exposing (Msg)
import Magnet.Utils exposing (decodeMessage)
import Mouse exposing (Position)
import WebSocket


type Msg
    = Magnets Magnet.Update.Msg
    | MouseMove Position
    | MouseUp Position
    | IncomingMessage String


init : ( Model, Cmd Msg )
init =
    emptyModel ! []


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Magnets msg_ ->
            let
                ( model_, cmds ) =
                    Magnet.Update.update model msg_
            in
            ( model_
            , Cmd.map Magnets cmds
            )

        MouseMove position ->
            let
                ( model_, cmds ) =
                    Magnet.Update.update model <| Magnet.Update.MouseMove position
            in
            ( model_
            , Cmd.map Magnets cmds
            )

        MouseUp position ->
            let
                ( model_, cmds ) =
                    Magnet.Update.update model <| Magnet.Update.MouseUp position
            in
            ( model_
            , Cmd.map Magnets cmds
            )

        IncomingMessage string ->
            case decodeString decodeMessage string of
                Ok message ->
                    case message of
                        AllMagnets magnets ->
                            { model | magnets = magnets } ! []

                        SingleMove move ->
                            let
                                ( model_, cmds ) =
                                    Magnet.Update.update model <| Magnet.Update.IncomingMove move
                            in
                            ( model_, Cmd.map Magnets cmds )

                Err _ ->
                    model ! []



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        ws =
            WebSocket.listen serverUrl IncomingMessage

        subs =
            if model.dragging then
                [ ws
                , -- Subscribe to mouse move and mouse up, only when dragging already.
                  Mouse.moves MouseMove
                , Mouse.ups MouseUp
                ]

            else
                [ ws ]
    in
    Sub.batch subs
