module Model exposing
    ( Drag
    , Id
    , IncomingMessage(AllMagnets, SingleMove)
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
    Dict String Magnet


type alias Model =
    { magnets : Magnets
    , dragData : Maybe Drag
    , drag : Draggable.State ()
    }


type IncomingMessage
    = AllMagnets Magnets
    | SingleMove Move


emptyModel : Model
emptyModel =
    { magnets = Dict.empty
    , dragData = Nothing
    , drag = Draggable.init
    }


serverUrl : String
serverUrl =
    --    "ws://localhost:3000"
    "wss://echoboard.itu.sh/"
