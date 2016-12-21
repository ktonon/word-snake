module Word.Word exposing (..)

import EnglishDictionary as Eng exposing (WordCheck)
import Html exposing (..)
import Html.Attributes exposing (class)
import Task
import Word.Score as Score exposing (..)
import Word.Validity as Validity exposing (..)


-- MODEL


type alias Word =
    { word : String
    , score : Score
    }


new : Eng.Config -> String -> Bonus -> ( Word, Cmd Msg )
new engConfig word bonus =
    ( Word word (newScore word bonus)
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
                    ( { word | score = word.score |> Score.validate check.exists }
                    , Cmd.none
                    )

                Err _ ->
                    ( word, Cmd.none )


order : Word -> Word -> Order
order a b =
    case Validity.order a.score.validity b.score.validity of
        EQ ->
            compare a.word b.word

        x ->
            x



-- VIEW


view : Word -> Html msg
view word =
    div [ getClass word ]
        [ div [ class "text col col-2" ] [ text (word.word |> String.toLower) ]
        , Score.view word.score
        ]


getClass : Word -> Html.Attribute msg
getClass word =
    class ("word " ++ (word.score.validity |> Validity.toString))
