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
setDragStart ({ id, word, position, drag, rotation } as magnet) position' =
    let
        side =
            if position'.x < position.x then
                Left
            else
                Right

        distanceFromMagnetCenter =
            sqrt << toFloat <| (position.x - position'.x) ^ 2 + (position.y - position'.y) ^ 2
    in
        Magnet id word position (Just (Drag position' position' distanceFromMagnetCenter side)) rotation


setDragAt : Magnet -> Position -> Magnet
setDragAt ({ id, word, position, drag, rotation } as magnet) position' =
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
                        toFloat (position'.y - current.y) * sideFactor * distanceFromCenter / 100

                _ ->
                    Debug.crash "no drag"

        rotation' =
            rotation + rotationDelta
    in
        Magnet id word position (Maybe.map (\{ start, current, distanceFromCenter, side } -> Drag start position' distanceFromCenter side) drag) rotation'


setDragEnd : Magnet -> Position -> Magnet
setDragEnd ({ id, word, position, drag, rotation } as magnet) position' =
    Magnet id word (getPosition magnet) Nothing rotation
