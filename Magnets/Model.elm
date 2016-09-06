module Magnets.Model exposing (..)

import Dict exposing (Dict, fromList)
import Magnet.Model exposing (Magnet)
import Mouse exposing (Position)


type alias Model =
    Dict Int Magnet


emptyModel : Model
emptyModel =
    -- Dict.empty
    Dict.fromList
        [ ( 1, Magnet 1 "nothing" (Position 200 200) Nothing )
        , ( 2, Magnet 2 "just" (Position 300 300) Nothing )
        ]
