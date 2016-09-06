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
setDragStart ({ id, word, position, drag } as magnet) position' =
    Magnet id word position (Just (Drag position' position'))


setDragAt : Magnet -> Position -> Magnet
setDragAt ({ id, word, position, drag } as magnet) position' =
    Magnet id word position (Maybe.map (\{ start } -> Drag start position') drag)


setDragEnd : Magnet -> Position -> Magnet
setDragEnd ({ id, word, position, drag } as magnet) position' =
    Magnet id word (getPosition magnet) Nothing
