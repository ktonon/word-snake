module Cell exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class)
import String


-- MODEL


type alias Model =
    { letter : String
    }


reset : String -> Model
reset letter =
    Model letter



-- UPDATE


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg cell =
    case msg of
        NoOp ->
            ( cell, Cmd.none )



-- VIEW


view : Model -> Html Msg
view cell =
    div [ class "p2 white bg-blue rounded" ]
        [ div [ class "h1" ] [ text cell.letter ]
        ]
