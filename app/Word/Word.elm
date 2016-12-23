module Word.Word exposing (..)

import EnglishDictionary as Eng exposing (WordCheck, WordDefinition)
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Task
import Word.Definition as Definition exposing (..)
import Word.Score as Score exposing (..)
import Word.Validity as Validity exposing (..)


-- MODEL


type alias Word =
    { word : String
    , score : Score
    , engConfig : Eng.Config
    , definition : Definition
    }


new : Eng.Config -> String -> Bonus -> ( Word, Cmd Msg )
new engConfig word bonus =
    ( Word word (newScore word bonus) engConfig Definition.empty
    , Task.attempt WordCheckResult
        (Eng.checkIsWord engConfig (word |> String.toLower))
    )


validate : Eng.Config -> (String -> Bonus) -> Word -> ( Word, Cmd Msg )
validate engConfig bonusFinder word =
    new engConfig word.word (bonusFinder word.word)



-- SAVE / RESTORE


toToken : Word -> String
toToken word =
    word.word


fromToken : String -> Result String Word
fromToken token =
    Ok (Word token (newScore token 0) (Eng.Config "") Definition.empty)



-- UPDATE


type Msg
    = ToggleDefinition
    | DefinitionMsg Definition.Msg
    | WordCheckResult (Result Eng.Error WordCheck)
    | WordDefinitionResult (Result Eng.Error WordDefinition)
    | HideDefinitionsOtherThan Word


update : Msg -> Word -> ( Word, Cmd Msg )
update msg word =
    case msg of
        ToggleDefinition ->
            case word.score.validity of
                Valid ->
                    case word.definition.state of
                        Empty ->
                            ( showDefinition word
                            , [ Eng.fetchDefinitions word.engConfig (word.word |> String.toLower)
                                    |> Task.attempt WordDefinitionResult
                              , Task.perform HideDefinitionsOtherThan (Task.succeed word)
                              ]
                                |> Cmd.batch
                            )

                        Hidden ->
                            ( showDefinition word
                            , Task.perform HideDefinitionsOtherThan (Task.succeed word)
                            )

                        Visible ->
                            ( hideDefinition word, Cmd.none )

                _ ->
                    ( word, Cmd.none )

        DefinitionMsg defMsg ->
            case defMsg of
                Dismiss ->
                    ( hideDefinition word, Cmd.none )

        WordCheckResult result ->
            case result of
                Ok check ->
                    ( { word | score = word.score |> Score.validate check.exists }
                    , Cmd.none
                    )

                Err _ ->
                    ( word, Cmd.none )

        WordDefinitionResult result ->
            case result of
                Ok def ->
                    ( { word | definition = Definition.load word.definition def }, Cmd.none )

                _ ->
                    ( word, Cmd.none )

        _ ->
            ( word, Cmd.none )


hideDefinition : Word -> Word
hideDefinition word =
    { word | definition = Definition.hide word.definition }


showDefinition : Word -> Word
showDefinition word =
    { word | definition = Definition.show word.definition }


order : Word -> Word -> Order
order a b =
    case Validity.order a.score.validity b.score.validity of
        EQ ->
            compare a.word b.word

        x ->
            x



-- VIEW


view : Word -> Html Msg
view word =
    div []
        [ div [ getClass word ]
            [ div
                [ class "text col col-8"
                , onClick ToggleDefinition
                ]
                [ text (word.word |> String.toLower) ]
            , div [ class "col col-3" ] [ Score.view word.score ]
            , div [ class "col col-1" ] []
            ]
        , definitionView word.definition
        ]


definitionView : Definition -> Html Msg
definitionView def =
    case def.state of
        Visible ->
            Html.map DefinitionMsg (Definition.view def)

        _ ->
            span [] []


getClass : Word -> Html.Attribute msg
getClass word =
    class ("word " ++ (word.score.validity |> Validity.toString))
