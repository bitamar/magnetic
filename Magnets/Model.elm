module Magnets.Model exposing (..)

import Dict exposing (Dict, fromList)
import Magnet.Model exposing (Magnet)


type alias Model =
    Dict String Magnet


emptyModel : Model
emptyModel =
    Dict.empty
