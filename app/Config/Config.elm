module Config.Config exposing (..)

import Config.Lang as Lang exposing (Lang(..))
import Json.Decode as D exposing (at)
import Window


-- MODEL


type alias Endpoints =
    { api : String
    , app : String
    , dictionaryApi : String
    }


type alias Model =
    { endpoints : Endpoints
    , isMobile : Bool
    , language : Lang
    , forkMe : Maybe String
    , windowSize : Window.Size
    }


empty : Model
empty =
    Model (Endpoints "" "" "")
        False
        Lang.default
        Nothing
        (Window.Size 0 0)


isEmpty : Model -> Bool
isEmpty model =
    model.endpoints.api |> String.isEmpty


setEndpoints : Endpoints -> Model -> Model
setEndpoints endpoints model =
    { model | endpoints = endpoints }


setWindowSize : Window.Size -> Model -> Model
setWindowSize ws model =
    { model | windowSize = ws }


sizeDidChange : Window.Size -> Model -> Bool
sizeDidChange size model =
    size.width /= model.windowSize.width || size.height /= model.windowSize.height


decoder : Endpoints -> D.Decoder Model
decoder endpoints =
    D.map5 Model
        (D.succeed endpoints)
        (at [ "isMobile" ] D.bool)
        (at [ "language" ] Lang.decoder)
        (D.maybe <| at [ "forkMe" ] D.string)
        (D.succeed (Window.Size 0 0))
