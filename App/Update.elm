module App.Update exposing (Msg(..), init, subscriptions, update)

import App.Model exposing (Model, emptyModel)
import Http.Update exposing (Msg, getMagnets)
import Magnets.Update exposing (Msg)
import Mouse exposing (Position)


type Msg
    = Http Http.Update.Msg
    | Magnets Magnets.Update.Msg
    | MouseMove Position
    | MouseUp Position


init : ( Model, Cmd Msg )
init =
    ( emptyModel, Cmd.map Http getMagnets )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Http msg_ ->
            let
                ( model_, cmds ) =
                    Http.Update.update msg_ model
            in
            ( model_
            , Cmd.map Http cmds
            )

        Magnets msg_ ->
            let
                ( model_, cmds ) =
                    Magnets.Update.update model msg_
            in
            ( model_
            , Cmd.map Magnets cmds
            )

        MouseMove position ->
            let
                ( model_, cmds ) =
                    Magnets.Update.update model <| Magnets.Update.MouseMove position
            in
            ( model_
            , Cmd.map Magnets cmds
            )

        MouseUp position ->
            let
                ( model_, cmds ) =
                    Magnets.Update.update model <| Magnets.Update.MouseUp position
            in
            ( model_
            , Cmd.map Magnets cmds
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Mouse.moves MouseMove
        , Mouse.ups MouseUp
        ]
