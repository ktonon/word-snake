module Cell exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class)
import Char
import Random exposing (Seed, initialSeed)
import String


-- MODEL


type alias Model =
    { letter : String
    }


init : Model
init =
    Model ""



-- UPDATE


type Msg
    = Shuffle
    | NewCode Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Shuffle ->
            let
                gen =
                    Random.int 65 90
            in
                ( model, Random.generate NewCode gen )

        NewCode code ->
            ( Model (String.fromChar (Char.fromCode code)), Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "p2 white bg-blue rounded" ]
        [ div [ class "h1" ] [ text model.letter ]
        ]
