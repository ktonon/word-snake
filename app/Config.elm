module Config exposing (..)

import Json.Decode exposing (at)


-- MODEL


type alias Model =
    { apiEndpoint : String
    }


empty : Model
empty =
    Model ""


isEmpty : Model -> Bool
isEmpty =
    .apiEndpoint >> String.isEmpty


decoder : Json.Decode.Decoder Model
decoder =
    Json.Decode.map Model
        (at [ "apiEndpoint" ] Json.Decode.string)
