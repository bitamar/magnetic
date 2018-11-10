module Model exposing
    ( Drag
    , Id
    , IncomingMessage(..)
    , Magnet
    , Magnets
    , Model
    , Move
    , Position
    , emptyModel
    , serverUrl
    )

import Dict exposing (Dict)
import Draggable


type alias Position =
    { x : Int
    , y : Int
    }


type alias Id =
    String


type alias Magnet =
    { id : Id
    , word : String
    , position : Position
    , rotation : Float
    , -- Whether someone else is currently moving it.
      locked : Bool
    }


type alias Move =
    { id : Id
    , x : Int
    , y : Int
    , rotation : Float
    }


type alias Drag =
    { magnet : Magnet
    , -- Number between -1 and 1, telling how much, and to which direction to
      -- rotate the magnet when the position changes.
      rotationFactor : Float
    }


type alias Magnets =
    Dict Id Magnet


type alias Model =
    { magnets : Magnets
    , dragData : Maybe Drag
    , drag : Draggable.State ()
    , newMagnetText : String
    }


type IncomingMessage
    = AllMagnets Magnets
    | SingleMagnet Magnet
    | SingleMove Move
    | Unlock Id


emptyModel : Model
emptyModel =
    let
        magnet =
            Magnet "0" "Loading..." { x = 500, y = 500 } 10 False
    in
    { magnets = Dict.singleton magnet.id magnet
    , dragData = Nothing
    , drag = Draggable.init
    , newMagnetText = ""
    }


serverUrl : String
serverUrl =
    --    "ws://localhost:3000"
    "wss://echoboard.itu.sh/"
