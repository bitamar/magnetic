module Magnet.Utils exposing
    ( decodeMagnets
    , decodeMessage
    , decodeMove
    , encodeMove
    , getPosition
    , setDragAt
    , setDragEnd
    , setDragStart
    )

import App.Model exposing (IncomingMessage(AllMagnets, SingleMove), Magnets)
import Json.Decode as Decode exposing (field)
import Json.Encode as Encode
import Magnet.Model exposing (Drag, Magnet, Move, Side(Left, Right))
import Mouse exposing (Position)


getPosition : Magnet -> Position
getPosition { position, drag } =
    case drag of
        Nothing ->
            position

        Just { start, current } ->
            Position
                (position.x + current.x - start.x)
                (position.y + current.y - start.y)


setDragStart : Magnet -> Position -> Magnet
setDragStart { id, word, position, rotation } position_ =
    let
        side =
            if position_.x < position.x then
                Left

            else
                Right

        distanceFromMagnetCenter =
            sqrt << toFloat <| (position.x - position_.x) ^ 2 + (position.y - position_.y) ^ 2
    in
    Magnet id word position (Just (Drag position_ position_ distanceFromMagnetCenter side)) rotation


setDragAt : Magnet -> Position -> Magnet
setDragAt { id, word, position, drag, rotation } position_ =
    let
        rotationDelta =
            case drag of
                Just { current, distanceFromCenter, side } ->
                    let
                        sideFactor =
                            case side of
                                Left ->
                                    -1

                                Right ->
                                    1
                    in
                    toFloat (position_.y - current.y) * sideFactor * distanceFromCenter / 100

                -- This branch isn't possible.
                _ ->
                    1

        rotation_ =
            rotation + rotationDelta
    in
    Magnet id word position (Maybe.map (\{ start, distanceFromCenter, side } -> Drag start position_ distanceFromCenter side) drag) rotation_


setDragEnd : Magnet -> Magnet
setDragEnd ({ id, word, rotation } as magnet) =
    Magnet id word (getPosition magnet) Nothing rotation


decodeMessage : Decode.Decoder IncomingMessage
decodeMessage =
    Decode.oneOf [ decodeSingleMoveMessage, decodeAllMagnnetsMessage ]


decodeSingleMoveMessage : Decode.Decoder IncomingMessage
decodeSingleMoveMessage =
    Decode.map SingleMove decodeMove


decodeAllMagnnetsMessage : Decode.Decoder IncomingMessage
decodeAllMagnnetsMessage =
    Decode.map AllMagnets decodeMagnets


encodePosition : Position -> Encode.Value
encodePosition position =
    Encode.object
        []


encodeMove : Magnet -> Encode.Value
encodeMove magnet =
    Encode.object
        [ ( "i", Encode.string magnet.id )
        , ( "x", Encode.int magnet.position.x )
        , ( "y", Encode.int magnet.position.y )
        , ( "r", Encode.float magnet.rotation )
        ]


decodeMove : Decode.Decoder Move
decodeMove =
    Decode.map4 Move
        (field "i" Decode.string)
        (field "x" Decode.int)
        (field "y" Decode.int)
        (field "r" Decode.float)


decodeMagnets : Decode.Decoder Magnets
decodeMagnets =
    Decode.dict decodeMagnet


decodeMagnet : Decode.Decoder Magnet
decodeMagnet =
    Decode.map5 Magnet
        (field "id" Decode.string)
        (field "word" Decode.string)
        (field "position" decodePosition)
        (Decode.maybe (field "drag" decodeDrag))
        (field "rotation" Decode.float)


decodeDrag : Decode.Decoder Drag
decodeDrag =
    Decode.map4 Drag
        (field "current" decodePosition)
        (field "start" decodePosition)
        (field "distanceFromCenter" Decode.float)
        (field "side" Decode.string |> Decode.andThen decodeSide)


decodeSide : String -> Decode.Decoder Side
decodeSide _ =
    Decode.succeed Magnet.Model.Left


decodePosition : Decode.Decoder Position
decodePosition =
    Decode.map2 Position
        (field "x" Decode.int)
        (field "y" Decode.int)
