module Utils exposing
    ( applyDrag
    , height
    , relativeCenter
    , updateMagnet
    , updateMagnetMove
    , width
    )

import Dict
import Draggable
import Json exposing (getMoveJson)
import Model exposing (Drag, Magnet, Magnets, Move, Position)


{-| Get the magnet width in pixels, according to the word length.
-}
width : Magnet -> Int
width { word } =
    -- 9 Is the approx character width in 14px monospace. 12 is extra padding.
    String.length word * 9 + 12


height : Int
height =
    30


{-| Replace the updated magnet on the magnets dictionary.
-}
updateMagnet : Magnets -> Magnet -> Magnets
updateMagnet magnets magnet =
    Dict.update magnet.id (\_ -> Just magnet) magnets


relativeCenter : Magnet -> Position
relativeCenter magnet =
    { x = width magnet // 2, y = height // 2 }


{-| Update the dragged magnet with the move delta, and produce the move json.
-}
applyDrag : Maybe Drag -> Draggable.Delta -> Maybe ( Drag, String )
applyDrag maybeDrag ( dx, dy ) =
    case maybeDrag of
        Just ({ magnet, rotationFactor } as drag) ->
            let
                -- horizontalGrab is negative when grabbing from the magnet's
                -- left, and positive when grabbing from the right. dy is
                -- negative when grabbing upwards, and positive when grabbing
                -- downwards.
                rotation_ =
                    magnet.rotation + rotationFactor * dy

                -- Limit the rotation between -90 and 90.
                rotation__ =
                    max (min rotation_ 90) -90

                position =
                    magnet.position

                position_ =
                    { position
                        | x = position.x + floor dx
                        , y = position.y + floor dy
                    }

                magnet_ =
                    { magnet | position = position_, rotation = rotation__ }

                moveJson =
                    getMoveJson magnet_
            in
            Just
                ( { drag | magnet = magnet_ }
                , moveJson
                )

        _ ->
            Nothing


{-| Apply a move to a magnet in the dictionary.
-}
updateMagnetMove : Magnets -> Move -> Magnets
updateMagnetMove magnets move =
    let
        position =
            Position move.x move.y

        applyMove maybeMagnet =
            case maybeMagnet of
                Just magnet ->
                    Just { magnet | position = position, rotation = move.rotation }

                _ ->
                    Nothing
    in
    Dict.update move.id applyMove magnets
