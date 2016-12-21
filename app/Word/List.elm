module Word.List exposing (..)

import ChildUpdate
import EnglishDictionary as Eng exposing (WordCheck)
import Html exposing (..)
import Html.Attributes exposing (..)
import Word.Candidate as Candidate exposing (Status(..))
import Word.Score as Score exposing (..)
import Word.Word as Word exposing (..)


-- MODEL


type alias Model =
    { words : List Word
    , engConfig : Eng.Config
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
    = WordMsg String Word.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        WordMsg word wordMsg ->
            ChildUpdate.updateMany
                Word.update
                .word
                .words
                (\m x -> { m | words = List.sortWith Word.order x })
                WordMsg
                word
                wordMsg
                model


candidateStatus : Model -> String -> Candidate.Status
candidateStatus model word =
    let
        n =
            word |> String.length
    in
        if n == 0 then
            Empty
        else if n <= 2 then
            TooShort
        else if model.words |> List.map (\w -> w.word) |> List.member word then
            Duplicate
        else
            Good


addWord : Model -> String -> Bonus -> ( Model, Cmd Msg )
addWord model text bonus =
    let
        ( word, wordCmd ) =
            Word.new model.engConfig text bonus
    in
        ( { model | words = List.sortWith Word.order (word :: model.words) }
        , Cmd.map (WordMsg text) wordCmd
        )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "word-list mt3" ]
        (div []
            [ div [ class "header col col-2" ] [ text "Score" ]
            , div [ class "header total col col-1" ] [ text (totalScore model |> Basics.toString) ]
            ]
            :: (wordsView model.words)
        )


wordsView : List Word -> List (Html Msg)
wordsView words =
    if List.isEmpty words then
        [ div [ class "no-words col col-3" ] [ text "no words yet" ] ]
    else
        List.map
            (\word ->
                Html.map (WordMsg word.word) (Word.view word)
            )
            words


totalScore : Model -> Int
totalScore model =
    model.words
        |> List.map .score
        |> List.map Score.toInt
        |> List.sum
