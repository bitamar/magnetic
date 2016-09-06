module App.Update exposing (init, subscriptions, update, Msg(..))

import App.Model exposing (..)
import Magnets.Update exposing (Msg)
import Mouse exposing (moves, Position)


type Msg
    = Magnets Magnets.Update.Msg
    | MouseMove Mouse.Position
    | MouseUp Mouse.Position


init : ( Model, Cmd Msg )
init =
    emptyModel ! []


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
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
