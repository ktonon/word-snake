module WordList exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)


-- MODEL


type alias Model =
    { words : List String
    }


reset : Model
reset =
    Model []



-- UPDATE


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )


canAddWord : Model -> String -> Bool
canAddWord model word =
    not (List.member word model.words)


addWord : Model -> String -> Model
addWord model word =
    { model | words = word :: model.words }



-- VIEW


view : Model -> Html Msg
view model =
    div
        [ style
            [ ( "margin", "30px 0" )
            , ( "font-size", "25px" )
            ]
        ]
        (List.map wordView model.words)


wordView : String -> Html Msg
wordView word =
    div [] [ text word ]
