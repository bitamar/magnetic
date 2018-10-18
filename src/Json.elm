module Json exposing
    ( decodeMagnets
    , decodeMouseOffsetWithMagnet
    , decodeMove
    , getMessage
    , getMoveJson
    )

import Json.Decode as Decode exposing (Decoder, decodeString, field)
import Json.Encode as Encode exposing (encode)
import Model exposing (IncomingMessage(..), Magnet, Magnets, Move, Position)


decodeMagnets : Decoder Magnets
decodeMagnets =
    let
        decodePosition : Decoder Position
        decodePosition =
            Decode.map2 Position
                (Decode.field "x" Decode.int)
                (Decode.field "y" Decode.int)

        decodeMagnet : Decoder Magnet
        decodeMagnet =
            Decode.map4 Magnet
                (field "id" Decode.string)
                (field "word" Decode.string)
                (field "position" decodePosition)
                (field "rotation" Decode.float)
    in
    Decode.dict decodeMagnet


getMessage : String -> Result String IncomingMessage
getMessage string =
    let
        decodeMessage : Decoder IncomingMessage
        decodeMessage =
            Decode.oneOf [ decodeSingleMoveMessage, decodeAllMagnetsMessage ]

        decodeSingleMoveMessage : Decoder IncomingMessage
        decodeSingleMoveMessage =
            Decode.map SingleMove decodeMove

        decodeAllMagnetsMessage : Decoder IncomingMessage
        decodeAllMagnetsMessage =
            Decode.map AllMagnets decodeMagnets
    in
    decodeString decodeMessage string


decodeMouseOffsetWithMagnet : Magnet -> Decoder ( Magnet, Position )
decodeMouseOffsetWithMagnet magnet =
    let
        decodeOffset =
            Decode.map2 Position
                (Decode.field "offsetX" Decode.int)
                (Decode.field "offsetY" Decode.int)
    in
    Decode.map2 (,)
        (Decode.succeed magnet)
        decodeOffset


decodeMove : Decoder Move
decodeMove =
    Decode.map4 Move
        (field "i" Decode.string)
        (field "x" Decode.int)
        (field "y" Decode.int)
        (field "r" Decode.float)


getMoveJson : Magnet -> String
getMoveJson magnet =
    let
        encodeMove : Encode.Value
        encodeMove =
            Encode.object
                [ ( "i", Encode.string magnet.id )
                , ( "x", Encode.int magnet.position.x )
                , ( "y", Encode.int magnet.position.y )
                , ( "r", Encode.float magnet.rotation )
                ]
    in
    encode 0 encodeMove
