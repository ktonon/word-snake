module Config.Config exposing (..)

import Config.Lang as Lang exposing (Lang(..))
import Json.Decode exposing (at)


-- MODEL


type alias Model =
    { apiEndpoint : String
    , language : Lang
    }


empty : Model
empty =
    Model "" Lang.default


isEmpty : Model -> Bool
isEmpty =
    .apiEndpoint >> String.isEmpty


decoder : Json.Decode.Decoder Model
decoder =
    Json.Decode.map2 Model
        (at [ "apiEndpoint" ] Json.Decode.string)
        (at [ "language" ] Lang.decoder)
