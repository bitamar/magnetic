module Utils exposing
    ( applyDrag
    , applyIncomingMove
    , createMagnet
    , getRectangleVertices
    , height
    , relativeCenter
    , stopDrag
    , updateMagnet
    , width
    )

import Collision exposing (Pt, collision)
import Dict exposing (insert, values)
import Draggable
import Json exposing (moveJson, newMagnetJson)
import Model exposing (Drag, Magnet, Magnets, Model, Move, Position, serverUrl)
import WebSocket


createMagnet : Model -> ( Model, Cmd msg )
createMagnet model =
    let
        cmd =
            if model.newMagnetText /= "" then
                WebSocket.send serverUrl <| newMagnetJson model.newMagnetText

            else
                Cmd.none
    in
    { model | newMagnetText = "" } ! [ cmd ]


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
    { x = width magnet // 2
    , y = height // 2
    }


{-| Update the dragged magnet with the move delta, and produce the move json.
-}
applyDrag : Magnets -> Drag -> Draggable.Delta -> ( Drag, Cmd msg )
applyDrag magnets ({ magnet, rotationFactor } as drag) ( dx, dy ) =
    let
        -- rotationFactor is negative when grabbing from the magnet's
        -- left, and positive when grabbing from the right. dy is
        -- negative when grabbing upwards, and positive when grabbing
        -- downwards.
        rotation =
            (magnet.rotation + rotationFactor * dy)
                |> trimFloat
                -- Limit the rotation between -90 and 90.
                |> clamp -90 90

        position =
            magnet.position

        position_ =
            { position
                | x = position.x + floor dx
                , y = position.y + floor dy
            }

        magnet_ =
            { magnet | position = position_, rotation = rotation }

        anyCollision =
            List.any (colliding magnet_) (values magnets)
    in
    if anyCollision then
        ( drag
        , Cmd.none
        )

    else
        ( { drag | magnet = magnet_ }
        , WebSocket.send serverUrl (moveJson magnet_)
        )


colliding : Magnet -> Magnet -> Bool
colliding magnet1 magnet2 =
    let
        poly1 =
            getRectangleVertices magnet1

        poly2 =
            getRectangleVertices magnet2
    in
    Maybe.withDefault False <| collision 0 ( poly1, polySupport ) ( poly2, polySupport )


{-| Apply a move to a magnet in the dictionary.
-}
applyIncomingMove : Magnets -> Move -> Magnets
applyIncomingMove magnets move =
    let
        position =
            Position move.x move.y

        applyMove maybeMagnet =
            case maybeMagnet of
                Just magnet ->
                    Just { magnet | position = position, rotation = move.rotation, locked = True }

                _ ->
                    Nothing
    in
    Dict.update move.id applyMove magnets


{-| Stop the drag and push the dragged magnet back to the dict.
-}
stopDrag : Model -> Model
stopDrag ({ magnets, dragData } as model) =
    let
        magnets_ =
            case dragData of
                Just { magnet } ->
                    insert magnet.id magnet magnets

                _ ->
                    magnets
    in
    { model | dragData = Nothing, magnets = magnets_ }


trimFloat : Float -> Float
trimFloat f =
    toFloat (floor (f * 100)) / 100


getRectangleVertices : Magnet -> List Pt
getRectangleVertices ({ position, rotation } as magnet) =
    let
        halfW =
            width magnet // 2

        halfH =
            height // 2

        cx =
            position.x + halfW

        cy =
            position.y + halfH

        p =
            point cx cy rotation
    in
    [ p (cx - halfW) (cy - halfH)
    , p (cx + halfW) (cy - halfH)
    , p (cx + halfW) (cy + halfH)
    , p (cx - halfW) (cy + halfH)
    ]


point : Int -> Int -> Float -> Int -> Int -> Pt
point cx cy r x y =
    let
        theta =
            degrees r

        cosT n =
            cos theta * toFloat n

        sinT n =
            sin theta * toFloat n

        rotatedX =
            cosT (x - cx) - sinT (y - cy)

        rotatedY =
            sinT (x - cx) + cosT (y - cy)
    in
    ( toFloat cx + rotatedX, toFloat cy + rotatedY )


dot : Pt -> Pt -> Float
dot ( x1, y1 ) ( x2, y2 ) =
    (x1 * x2) + (y1 * y2)


polySupport : List Pt -> Pt -> Maybe Pt
polySupport list d =
    let
        dotList =
            List.map (dot d) list

        decorated =
            List.map2 (,) dotList list

        max =
            List.maximum decorated
    in
    case max of
        Just ( _, p ) ->
            Just p

        _ ->
            Nothing
