module Word.Score exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class)
import Word.Validity as Validity exposing (Validity(..))


-- MODEL


type alias Base =
    Int


type alias Bonus =
    Int


type alias Score =
    { base : Base
    , bonus : Bonus
    , validity : Validity
    }


newScore : String -> Bonus -> Score
newScore word bonus =
    let
        n =
            String.length word
    in
        Score
            (if n <= 2 then
                0
             else if n <= 4 then
                1
             else if n == 5 then
                2
             else if n == 6 then
                3
             else if n == 7 then
                5
             else
                11
            )
            bonus
            Unknown


validate : Bool -> Score -> Score
validate isValid score =
    { score
        | validity =
            if isValid then
                Valid
            else
                Invalid
    }


toInt : Score -> Int
toInt score =
    case score.validity of
        Valid ->
            score.base * score.bonus

        Invalid ->
            -1

        Unknown ->
            0



-- VIEW


view : Score -> Html msg
view score =
    let
        icon =
            case score.validity of
                Unknown ->
                    " pt1 fa fa-spinner"

                _ ->
                    ""
    in
        div [ class ("score " ++ icon) ]
            [ text (score |> toString) ]


toString : Score -> String
toString score =
    case score.validity of
        Valid ->
            score |> toStringIfValid

        Invalid ->
            "-1"

        Unknown ->
            ""


toStringIfValid : Score -> String
toStringIfValid score =
    (score.base |> Basics.toString)
        ++ (if score.bonus > 1 then
                " x " ++ (score.bonus |> Basics.toString)
            else
                ""
           )
