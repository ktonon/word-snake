module WordList exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import ChildUpdate


-- MODEL


type alias Model =
    { words : List Word
    }


type alias Word =
    { word : String
    , bonus : Int
    }


reset : Model
reset =
    Model []



-- UPDATE FOR PARENT


type alias HasOne model =
    { model | wordList : Model }


updateOne : (Msg -> msg) -> Msg -> HasOne m -> ( HasOne m, Cmd msg )
updateOne =
    ChildUpdate.updateOne update .wordList (\m x -> { m | wordList = x })



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
    not
        (model.words
            |> List.map (\w -> w.word)
            |> List.member word
        )


addWord : Model -> Word -> Model
addWord model word =
    { model | words = word :: model.words }



-- VIEW


view : Model -> Html Msg
view model =
    div
        [ style
            [ ( "margin", "30px 0" )
            , ( "font-size", "25px" )
            , ( "text-align", "right" )
            ]
        ]
        (List.map wordView model.words)


wordView : Word -> Html Msg
wordView word =
    let
        bonusText =
            if (word.bonus > 1) then
                "(x" ++ (toString word.bonus) ++ ") "
            else
                ""
    in
        div [] [ text (bonusText ++ word.word) ]
