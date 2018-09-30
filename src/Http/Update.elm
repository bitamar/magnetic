module Http.Update exposing (Msg, getMagnets, update)

import App.Model exposing (Magnets, Model, emptyModel)
import Http
import Json.Decode exposing (Decoder, andThen, dict, field, float, int, map2, map4, map5, maybe, string, succeed)
import Magnet.Model exposing (Drag, Magnet, Side)
import Mouse exposing (Position)


type Msg
    = GotMagnets (Result Http.Error Magnets)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotMagnets result ->
            case result of
                Ok magnets ->
                    ( { emptyModel | magnets = magnets }
                    , Cmd.none
                    )

                Err _ ->
                    ( model
                    , Cmd.none
                    )


getMagnets : Cmd Msg
getMagnets =
    let
        url =
            -- "http://localhost:8080/"
            "https://peaceful-refuge.herokuapp.com/"
    in
    Http.send GotMagnets (Http.get url decodeMagnets)


decodeMagnets : Json.Decode.Decoder Magnets
decodeMagnets =
    dict decodeMagnet


decodeMagnet : Decoder Magnet
decodeMagnet =
    map5 Magnet
        (field "id" string)
        (field "word" string)
        (field "position" decodePosition)
        (maybe (field "drag" decodeDrag))
        (field "rotation" float)


decodeDrag : Decoder Drag
decodeDrag =
    map4 Drag
        (field "current" decodePosition)
        (field "start" decodePosition)
        (field "distanceFromCenter" float)
        (field "side" string |> andThen decodeSide)


decodeSide : String -> Decoder Side
decodeSide _ =
    succeed Magnet.Model.Left


decodePosition : Decoder Position
decodePosition =
    map2 Position
        (field "x" int)
        (field "y" int)
