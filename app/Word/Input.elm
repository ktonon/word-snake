module Word.Input exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, style)
import Word.Candidate as Candidate exposing (statusClass, Status(..))
import Word.Score as Score exposing (Score)


-- VIEW


view : String -> Score -> Candidate.Status -> Html msg
view word score status =
    let
        showWord =
            if String.isEmpty word then
                "Start typing..."
            else
                word
    in
        div
            [ statusClass status "word-input clearfix" ]
            [ div [ class "box rounded center col col-8" ] [ text showWord ]
            , div [ class "bonus pl2 col col-4", style [ ( "padding-right", "20px" ) ] ]
                (bonusView status score)
            ]


bonusView : Candidate.Status -> Score -> List (Html msg)
bonusView status score =
    case status of
        TooShort ->
            [ text "too short" ]

        Duplicate ->
            [ text "duplicate" ]

        Good ->
            [ text (score |> Score.toStringIfValid) ]

        _ ->
            []
