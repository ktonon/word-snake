module Config.Config exposing (..)

import Config.Lang as Lang exposing (Lang(..))
import Json.Decode as D exposing (at)
import Window


-- MODEL


type alias Model =
    { apiEndpoint : String
    , isMobile : Bool
    , language : Lang
    , forkMe : Maybe String
    , windowSize : Window.Size
    }


empty : Model
empty =
    Model ""
        False
        Lang.default
        Nothing
        (Window.Size 0 0)


isEmpty : Model -> Bool
isEmpty =
    .apiEndpoint >> String.isEmpty


setWindowSize : Window.Size -> Model -> Model
setWindowSize ws model =
    { model | windowSize = ws }


sizeDidChange : Window.Size -> Model -> Bool
sizeDidChange size model =
    size.width /= model.windowSize.width || size.height /= model.windowSize.height


decoder : D.Decoder Model
decoder =
    D.map5 Model
        (at [ "apiEndpoint" ] D.string)
        (at [ "isMobile" ] D.bool)
        (at [ "language" ] Lang.decoder)
        (D.maybe <| at [ "forkMe" ] D.string)
        (D.succeed (Window.Size 0 0))
