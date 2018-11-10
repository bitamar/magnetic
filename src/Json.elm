module Json exposing
    ( decodeMagnets
    , decodeMouseOffsetWithMagnet
    , getMessage
    , moveJson
    , newMagnetJson
    )

import Json.Decode as Decode exposing (Decoder, decodeString, field)
import Json.Encode as Encode exposing (encode)
import Model exposing (IncomingMessage(..), Magnet, Magnets, Move, Position)


decodeMagnet : Decoder Magnet
decodeMagnet =
    let
        decodePosition : Decoder Position
        decodePosition =
            Decode.map2 Position
                (field "x" Decode.int)
                (field "y" Decode.int)
    in
    Decode.map5 Magnet
        (field "i" Decode.string)
        (field "w" Decode.string)
        decodePosition
        (field "r" Decode.float)
        (field "l" Decode.bool)


decodeMagnets : Decoder Magnets
decodeMagnets =
    Decode.dict decodeMagnet


getMessage : String -> Result String IncomingMessage
getMessage =
    let
        decodeMove : Decoder Move
        decodeMove =
            Decode.map4 Move
                (field "i" Decode.string)
                (field "x" Decode.int)
                (field "y" Decode.int)
                (field "r" Decode.float)

        decodeSingleMagnet : Decoder IncomingMessage
        decodeSingleMagnet =
            Decode.map SingleMagnet decodeMagnet

        decodeSingleMoveMessage : Decoder IncomingMessage
        decodeSingleMoveMessage =
            Decode.map SingleMove decodeMove

        decodeAllMagnetsMessage : Decoder IncomingMessage
        decodeAllMagnetsMessage =
            Decode.map AllMagnets decodeMagnets

        decodeUnlockMessage : Decoder IncomingMessage
        decodeUnlockMessage =
            Decode.map Unlock (field "unlock" Decode.string)
    in
    decodeString <|
        Decode.oneOf
            [ decodeSingleMagnet
            , decodeSingleMoveMessage
            , decodeAllMagnetsMessage
            , decodeUnlockMessage
            ]


decodeMouseOffsetWithMagnet : Magnet -> Decoder ( Magnet, Position )
decodeMouseOffsetWithMagnet magnet =
    let
        decodeOffset =
            Decode.map2 Position
                (field "offsetX" Decode.int)
                (field "offsetY" Decode.int)
    in
    Decode.map2 (,)
        (Decode.succeed magnet)
        decodeOffset


moveJson : Magnet -> String
moveJson magnet =
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


newMagnetJson : String -> String
newMagnetJson word =
    encode 0 <| Encode.object [ ( "add", Encode.string word ) ]
