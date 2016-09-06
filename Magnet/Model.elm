module Magnet.Model exposing (..)

import Mouse exposing (Position)


type alias Magnet =
    { id : Int
    , word : String
    , position : Position
    , drag : Maybe Drag
    }


type alias Model =
    Magnet


type alias Drag =
    { start : Position
    , current : Position
    }