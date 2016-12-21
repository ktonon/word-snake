module Word.List exposing (..)

import ChildUpdate
import EnglishDictionary as Eng exposing (WordCheck)
import Html exposing (..)
import Html.Attributes exposing (..)
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
            Word.updateMany WordMsg word wordMsg model


canAddWord : Model -> String -> Bool
canAddWord model word =
    not
        (model.words
            |> List.map (\w -> w.word)
            |> List.member word
        )


addWord : Model -> String -> Bonus -> ( Model, Cmd Msg )
addWord model text bonus =
    let
        ( word, wordCmd ) =
            Word.new model.engConfig text bonus
    in
        ( { model | words = word :: model.words }, Cmd.map (WordMsg text) wordCmd )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "word-list" ] (List.map Word.view model.words)
