module WordList exposing (..)

import ChildUpdate
import EnglishDictionary as Eng exposing (WordCheck)
import Html exposing (..)
import Html.Attributes exposing (..)
import Task


-- MODEL


type alias Model =
    { words : List Word
    , engConfig : Eng.Config
    }


type alias Word =
    { word : String
    , bonus : Int
    , isValid : Maybe Bool
    }


reset : String -> Model
reset apiEndpoint =
    Model [] (Eng.Config apiEndpoint)



-- UPDATE FOR PARENT


type alias HasOne model =
    { model | wordList : Model }


updateOne : (Msg -> msg) -> Msg -> HasOne m -> ( HasOne m, Cmd msg )
updateOne =
    ChildUpdate.updateOne update .wordList (\m x -> { m | wordList = x })



-- UPDATE


type Msg
    = WordCheckResult (Result Eng.Error WordCheck)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        WordCheckResult result ->
            case result of
                Ok check ->
                    ( updateWord model check, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )


updateWord : Model -> WordCheck -> Model
updateWord model check =
    let
        newWords =
            model.words
                |> List.map
                    (\w ->
                        if (w.word |> String.toLower) == check.word then
                            { w | isValid = Just check.exists }
                        else
                            w
                    )
    in
        { model | words = newWords }


canAddWord : Model -> String -> Bool
canAddWord model word =
    not
        (model.words
            |> List.map (\w -> w.word)
            |> List.member word
        )


addWord : Model -> Word -> ( Model, Cmd Msg )
addWord model word =
    ( { model | words = word :: model.words }
    , Task.attempt WordCheckResult
        (Eng.checkIsWord model.engConfig
            (word.word |> String.toLower)
        )
    )



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
        case word.isValid of
            Just valid ->
                if valid then
                    div [] [ text (bonusText ++ word.word) ]
                else
                    div [ class "red" ]
                        [ text
                            ("(0) " ++ word.word)
                        ]

            Nothing ->
                div [] [ text word.word ]
