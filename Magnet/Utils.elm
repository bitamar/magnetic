module Magnet.Utils exposing (..)

import Magnet.Model exposing (..)
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
setDragStart ({ id, word, position, drag, rotation } as magnet) position_ =
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
setDragAt ({ id, word, position, drag, rotation } as magnet) position_ =
    let
        rotationDelta =
            case drag of
                Just { start, current, distanceFromCenter, side } ->
                    let
                        sideFactor =
                            case side of
                                Left ->
                                    -1

                                Right ->
                                    1
                    in
                    toFloat (position_.y - current.y) * sideFactor * distanceFromCenter / 100

                _ ->
                    Debug.crash "no drag"

        rotation_ =
            rotation + rotationDelta
    in
    Magnet id word position (Maybe.map (\{ start, current, distanceFromCenter, side } -> Drag start position_ distanceFromCenter side) drag) rotation_


setDragEnd : Magnet -> Position -> Magnet
setDragEnd ({ id, word, position, drag, rotation } as magnet) position_ =
    Magnet id word (getPosition magnet) Nothing rotation
