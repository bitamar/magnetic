module App.Update exposing (init, subscriptions, update, Msg(..))

import App.Model exposing (..)
import Http.Update exposing (init, Msg)
import Magnets.Update exposing (Msg)
import Mouse exposing (moves, Position)


type Msg
    = Http Http.Update.Msg
    | Magnets Magnets.Update.Msg
    | MouseMove Mouse.Position
    | MouseUp Mouse.Position


init : ( Model, Cmd Msg )
init =
    ( emptyModel, Cmd.map Http Http.Update.init )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Http msg ->
            let
                ( magnets', cmds ) =
                    Http.Update.update msg model.magnets
            in
                ( { model | magnets = magnets' }
                , Cmd.map Http cmds
                )

        Magnets msg ->
            let
                ( magnets', cmds ) =
                    Magnets.Update.update model.magnets msg
            in
                ( { model | magnets = magnets' }
                , Cmd.map Magnets cmds
                )

        MouseMove position ->
            let
                ( magnets', cmds ) =
                    Magnets.Update.update model.magnets <| Magnets.Update.MouseMove position
            in
                ( { model | magnets = magnets' }
                , Cmd.map Magnets cmds
                )

        MouseUp position ->
            let
                ( magnets', cmds ) =
                    Magnets.Update.update model.magnets <| Magnets.Update.MouseUp position
            in
                ( { model | magnets = magnets' }
                , Cmd.map Magnets cmds
                )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Mouse.moves MouseMove
        , Mouse.ups MouseUp
        ]
