module Http.Update exposing (..)

import Dict
import Http
import Json.Decode exposing (..)
import Magnets.Model exposing (Model)
import Magnet.Model exposing (Drag, Magnet)
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
    object4 Magnet
        ("id" := string)
        ("word" := string)
        ("position" := decodePosition)
        (maybe ("drag" := decodeDrag))


decodeDrag : Decoder Drag
decodeDrag =
    object2 Drag
        ("current" := decodePosition)
        ("start" := decodePosition)


decodePosition : Decoder Position
decodePosition =
    object2 Position
        ("x" := int)
        ("y" := int)
