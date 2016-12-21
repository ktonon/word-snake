module Word.Candidate exposing (..)

import Html
import Html.Attributes exposing (class)


-- MODEL


type Status
    = Empty
    | TooShort
    | Duplicate
    | Good


statusClass : Status -> String -> Html.Attribute msg
statusClass status extraClass =
    class
        (extraClass
            ++ " word-candidate status-"
            ++ case status of
                Empty ->
                    "empty"

                TooShort ->
                    "too-short"

                Duplicate ->
                    "duplicate"

                Good ->
                    "good"
        )
