module Word.Definition exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import EnglishDictionary as Eng exposing (WordDefinition)
import PartOfSpeech


-- MODEL


type alias Definition =
    { def : WordDefinition
    }



-- UPDATE


type Msg
    = Dismiss



-- VIEW


view : Definition -> Html Msg
view def =
    ul [ class "definition-list", onClick Dismiss ]
        (def.def.definitions
            |> List.take 2
            |> List.map viewDef
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
