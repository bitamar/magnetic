module App.Model exposing (IncomingMessage(..), Magnets, Model, emptyModel, serverUrl)

import Dict exposing (Dict)
import Magnet.Model exposing (Magnet, Move)


type alias Magnets =
    Dict String Magnet


type alias Model =
    { magnets : Magnets
    , dragging : Bool
    }


type IncomingMessage
    = AllMagnets Magnets
    | SingleMove Move


emptyModel : Model
emptyModel =
    { magnets = Dict.empty
    , dragging = False
    }


serverUrl : String
serverUrl =
    "ws://localhost:3000"
