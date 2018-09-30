module App.Model exposing (Model, emptyModel)

import Dict exposing (Dict)
import Magnet.Model exposing (Magnet)


type alias Model =
    Dict String Magnet


emptyModel : Model
emptyModel =
    Dict.empty
