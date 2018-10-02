module Magnet.Model exposing (Drag, Magnet, Move, Side(Left, Right))

import Mouse exposing (Position)


type alias Magnet =
    { id : String
    , word : String
    , position : Position
    , drag : Maybe Drag
    , rotation : Float
    }


type alias Move =
    { id : String
    , x : Int
    , y : Int
    , rotation : Float
    }


type Side
    = Left
    | Right


type alias Drag =
    { start : Position
    , current : Position
    , -- How far from its center the magnet is dragged from.
      distanceFromCenter : Float
    , -- Whether the magnet is dragged from its right or left side.
      side : Side
    }
