module Config.Config exposing (..)

import Config.Lang as Lang exposing (Lang(..))
import Json.Decode exposing (at)
import Window


-- MODEL


type alias Model =
    { apiEndpoint : String
    , language : Lang
    , forkMe : Maybe String
    , windowSize : Window.Size
    }


empty : Model
empty =
    Model ""
        Lang.default
        Nothing
        (Window.Size 0 0)


isEmpty : Model -> Bool
isEmpty =
    .apiEndpoint >> String.isEmpty


setWindowSize : Window.Size -> Model -> Model
setWindowSize ws model =
    { model | windowSize = ws }


decoder : Json.Decode.Decoder Model
decoder =
    Json.Decode.map4 Model
        (at [ "apiEndpoint" ] Json.Decode.string)
        (at [ "language" ] Lang.decoder)
        (Json.Decode.maybe <| at [ "forkMe" ] Json.Decode.string)
        (Json.Decode.succeed (Window.Size 0 0))
