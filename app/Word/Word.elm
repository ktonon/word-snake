module Word.Word exposing (..)

import ChildUpdate
import EnglishDictionary as Eng exposing (WordCheck)
import Html exposing (..)
import Html.Attributes exposing (class)
import Task
import Word.Score exposing (..)


-- MODEL


type alias Word =
    { word : String
    , score : Score
    , isValid : Maybe Bool
    }


new : Eng.Config -> String -> Bonus -> ( Word, Cmd Msg )
new engConfig word bonus =
    ( Word word (newScore word bonus) Nothing
    , Task.attempt WordCheckResult
        (Eng.checkIsWord engConfig (word |> String.toLower))
    )



-- UPDATE FOR PARENT


type alias HasMany model =
    { model | words : List Word }


updateMany : (String -> Msg -> msg) -> String -> Msg -> HasMany m -> ( HasMany m, Cmd msg )
updateMany =
    ChildUpdate.updateMany update .word .words (\m x -> { m | words = x })



-- UPDATE


type Msg
    = WordCheckResult (Result Eng.Error WordCheck)


update : Msg -> Word -> ( Word, Cmd Msg )
update msg word =
    case msg of
        WordCheckResult result ->
            case result of
                Ok check ->
                    ( { word | isValid = Just check.exists }, Cmd.none )

                Err _ ->
                    ( word, Cmd.none )



-- VIEW


view : Word -> Html msg
view word =
    div [ getClass word ] [ text word.word ]


getClass : Word -> Html.Attribute msg
getClass word =
    class
        ("word "
            ++ (case word.isValid of
                    Just valid ->
                        if valid then
                            "valid"
                        else
                            "invalid"

                    Nothing ->
                        "unknown"
               )
        )
