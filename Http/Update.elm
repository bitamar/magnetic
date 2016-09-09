module Http.Update exposing (..)

import Dict
import Http
import Json.Decode exposing (..)
import Magnets.Model exposing (Model)
import Magnet.Model exposing (Drag, Magnet, Side)
import Mouse exposing (Position)
import Task


init : Cmd Msg
init =
    getMagnets


type Msg
    = FetchSucceed Model
    | FetchFail Http.Error


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchSucceed model' ->
            ( model', Cmd.none )

        FetchFail _ ->
            ( model, Cmd.none )


getMagnets : Cmd Msg
getMagnets =
    let
        url =
            -- "http://localhost:8080/"
            "https://peaceful-refuge.herokuapp.com/"
    in
        Task.perform FetchFail FetchSucceed (Http.get decodeMagnets url)


decodeMagnets : Json.Decode.Decoder (Dict.Dict String Magnet)
decodeMagnets =
    dict decodeMagnet


decodeMagnet : Decoder Magnet
decodeMagnet =
    object5 Magnet
        ("id" := string)
        ("word" := string)
        ("position" := decodePosition)
        (maybe ("drag" := decodeDrag))
        ("rotation" := float)


decodeDrag : Decoder Drag
decodeDrag =
    object4 Drag
        ("current" := decodePosition)
        ("start" := decodePosition)
        ("distanceFromCenter" := float)
        (("side" := string) `andThen` decodeSide)


decodeSide : String -> Decoder Side
decodeSide side =
    succeed (Magnet.Model.Left)


decodePosition : Decoder Position
decodePosition =
    object2 Position
        ("x" := int)
        ("y" := int)
