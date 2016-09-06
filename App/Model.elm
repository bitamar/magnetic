module App.Model exposing (emptyModel, Model)

import Magnets.Model exposing (emptyModel, Model)


type alias Model =
    { magnets : Magnets.Model.Model
    }


emptyModel : Model
emptyModel =
    { magnets = Magnets.Model.emptyModel
    }
