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
    , definition : Maybe Definition
    }


new : Eng.Config -> String -> Bonus -> ( Word, Cmd Msg )
new engConfig word bonus =
    ( Word word (newScore word bonus) engConfig Nothing
    , Task.attempt WordCheckResult
        (Eng.checkIsWord engConfig (word |> String.toLower))
    )



-- UPDATE


type Msg
    = ToggleDefinition
    | DefinitionMsg Definition.Msg
    | WordCheckResult (Result Eng.Error WordCheck)
    | WordDefinitionResult (Result Eng.Error WordDefinition)


update : Msg -> Word -> ( Word, Cmd Msg )
update msg word =
    case msg of
        ToggleDefinition ->
            case word.score.validity of
                Valid ->
                    case word.definition of
                        Just _ ->
                            ( { word | definition = Nothing }, Cmd.none )

                        Nothing ->
                            ( word
                            , Eng.fetchDefinitions word.engConfig (word.word |> String.toLower)
                                |> Task.attempt WordDefinitionResult
                            )

                _ ->
                    ( word, Cmd.none )

        DefinitionMsg defMsg ->
            case defMsg of
                Dismiss ->
                    ( { word | definition = Nothing }, Cmd.none )

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
                    ( { word | definition = Just (Definition def) }, Cmd.none )

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


view : Word -> Html Msg
view word =
    div []
        [ div [ getClass word ]
            [ div
                [ class "text col col-2"
                , onClick ToggleDefinition
                ]
                [ text (word.word |> String.toLower) ]
            , Score.view word.score
            ]
        , definitionView word.definition
        ]


definitionView : Maybe Definition -> Html Msg
definitionView maybeDef =
    case maybeDef of
        Just def ->
            Html.map DefinitionMsg (Definition.view def)

        Nothing ->
            span [] []


getClass : Word -> Html.Attribute msg
getClass word =
    class ("word " ++ (word.score.validity |> Validity.toString))
