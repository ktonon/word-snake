module Word.Word exposing (..)

import EnglishDictionary as Eng exposing (WordCheck)
import Html exposing (..)
import Html.Attributes exposing (class)
import Task
import Word.Score as Score exposing (..)


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



-- UPDATE


type Msg
    = WordCheckResult (Result Eng.Error WordCheck)


update : Msg -> Word -> ( Word, Cmd Msg )
update msg word =
    case msg of
        WordCheckResult result ->
            case result of
                Ok check ->
                    ( { word
                        | isValid = Just check.exists
                        , score =
                            if check.exists then
                                word.score
                            else
                                Score.invalid
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( word, Cmd.none )


order : Word -> Word -> Order
order a b =
    case ( a.isValid, b.isValid ) of
        ( Just aValid, Just bValid ) ->
            if aValid == bValid then
                compare a.word b.word
            else if aValid then
                LT
            else
                GT

        ( Nothing, Nothing ) ->
            compare a.word b.word

        ( Just aValid, _ ) ->
            GT

        ( _, _ ) ->
            LT



-- VIEW


view : Word -> Html msg
view word =
    div [ getClass word ]
        [ div [ class "text col col-2" ] [ text (word.word |> String.toLower) ]
        , Score.view word.score
        ]


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
