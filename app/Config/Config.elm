module Config.Config exposing (..)

import Config.Lang as Lang exposing (Lang(..))
import Json.Decode exposing (at)


-- MODEL


type alias Model =
    { apiEndpoint : String
    , language : Lang
    , forkMe : Maybe String
    }


empty : Model
empty =
    Model "" Lang.default Nothing


isEmpty : Model -> Bool
isEmpty =
    .apiEndpoint >> String.isEmpty


decoder : Json.Decode.Decoder Model
decoder =
    Json.Decode.map3 Model
        (at [ "apiEndpoint" ] Json.Decode.string)
        (at [ "language" ] Lang.decoder)
        (Json.Decode.maybe <| at [ "forkMe" ] Json.Decode.string)
