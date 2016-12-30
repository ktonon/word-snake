module Word.Input exposing (..)

import GameMode exposing (GameMode(..))
import Html exposing (..)
import Html.Attributes exposing (class, style)
import Word.Candidate as Candidate exposing (statusClass, Status(..))
import Word.Score as Score exposing (Score)


-- VIEW


view : GameMode -> String -> Score -> Candidate.Status -> Html msg -> Html msg
view gameMode word score status timer =
    let
        showWord =
            case gameMode of
                Waiting ->
                    "Press any key to start"

                Playing ->
                    if String.isEmpty word then
                        "Start typing..."
                    else
                        word

                _ ->
                    ""
    in
        div
            [ statusClass status
                ("word-input clearfix " ++ (gameMode |> GameMode.toString))
            ]
            [ div [ class "timer col col-5" ] [ timer ]
            , div [ class "box rounded px2 col col-7" ]
                [ text showWord
                , div [ class "bonus right" ] (bonusView status score)
                ]
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
            [ div [ class "white" ] [ text "." ] ]
