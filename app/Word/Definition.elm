module Word.Definition exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import EnglishDictionary as Eng exposing (WordDefinition)
import PartOfSpeech


-- MODEL


type alias Definition =
    { def : Maybe WordDefinition
    , state : State
    }


type State
    = Empty
    | Hidden
    | Visible


empty : Definition
empty =
    Definition Nothing Empty


load : Definition -> WordDefinition -> Definition
load def wordDef =
    { def | def = Just wordDef }


show : Definition -> Definition
show def =
    { def | state = Visible }


hide : Definition -> Definition
hide def =
    { def
        | state =
            if def.state == Visible then
                Hidden
            else
                def.state
    }



-- UPDATE


type Msg
    = Dismiss



-- VIEW


view : Definition -> Html Msg
view def =
    ul [ class "definition-list", onClick Dismiss ]
        (case def.def of
            Just wordDef ->
                (wordDef.definitions
                    |> List.take 2
                    |> List.map viewDef
                )

            Nothing ->
                [ text "Loading definition..." ]
        )


viewDef : Eng.Definition -> Html msg
viewDef def =
    li [ class "definition" ]
        [ span [ class "part-of-speech" ]
            [ text
                ((def.partOfSpeech
                    |> PartOfSpeech.toString
                    |> String.toLower
                 )
                    ++ ": "
                )
            ]
        , text (def.meaning)
        ]
