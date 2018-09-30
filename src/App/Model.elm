module App.Model exposing (Magnets, Model, emptyModel)

import Dict exposing (Dict)
import Magnet.Model exposing (Magnet)


type alias Magnets =
    Dict String Magnet


type alias Model =
    { magnets : Magnets
    , dragging : Bool
    }


emptyModel : Model
emptyModel =
    { magnets = Dict.empty
    , dragging = False
    }
