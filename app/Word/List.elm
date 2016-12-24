module Word.List exposing (..)

import ChildUpdate
import EnglishDictionary as Eng exposing (WordCheck)
import Exts.Json.Decode exposing (parseWith)
import GameMode exposing (GameMode(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Encode as J
import Json.Decode as D
import Result.Extra
import Word.Candidate as Candidate exposing (Status(..))
import Word.Score as Score exposing (..)
import Word.Word as Word exposing (..)


-- MODEL


type alias Model =
    { engConfig : Eng.Config
    , words : List Word
    }


reset : String -> Model
reset apiEndpoint =
    Model (Eng.Config apiEndpoint) []



-- SAVE / RESTORE


toJsonValue : Model -> J.Value
toJsonValue model =
    model |> toToken |> J.string


decoder : D.Decoder Model
decoder =
    D.string |> D.andThen (parseWith fromToken)


toToken : Model -> String
toToken model =
    model.words
        |> List.map Word.toToken
        |> String.join ","


fromToken : String -> Result String Model
fromToken token =
    if String.isEmpty token then
        Model (Eng.Config "") [] |> Ok
    else
        token
            |> String.split ","
            |> List.map Word.fromToken
            |> Result.Extra.combine
            |> Result.map (Eng.Config "" |> Model)



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
            case wordMsg of
                HideDefinitionsOtherThan exceptWord ->
                    ( { model
                        | words =
                            model.words
                                |> List.map
                                    (\other ->
                                        if other.word == exceptWord.word then
                                            other
                                        else
                                            Word.hideDefinition other
                                    )
                      }
                    , Cmd.none
                    )

                _ ->
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


validate : String -> (String -> Bonus) -> Model -> ( Model, Cmd Msg )
validate apiEndpoint bonusFinder model =
    let
        engConfig =
            Eng.Config apiEndpoint

        ( newWords, cmds ) =
            model.words
                |> List.map (Word.validate engConfig bonusFinder)
                |> List.map (\( w, c ) -> ( w, Cmd.map (WordMsg w.word) c ))
                |> List.unzip
    in
        ( { model
            | engConfig = engConfig
            , words = newWords
          }
        , Cmd.batch cmds
        )



-- VIEW


view : GameMode -> Model -> Html Msg
view gameMode model =
    div [ class "word-list mt3 clearfix" ]
        (div []
            [ div [ class "header col col-6" ] [ text "Score" ]
            , div [ class "header total col col-5" ] [ text (totalScore model |> Basics.toString) ]
            , div [ class "col col-1" ] []
            ]
            :: (wordsView gameMode model.words)
        )


wordsView : GameMode -> List Word -> List (Html Msg)
wordsView gameMode words =
    if List.isEmpty words then
        [ div [ class "no-words col col-12" ]
            [ text
                (case gameMode of
                    Playing ->
                        "no words yet"

                    _ ->
                        "no words"
                )
            ]
        ]
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
