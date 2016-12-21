module Word.Score exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class)


-- MODEL


type alias Base =
    Int


type alias Bonus =
    Int


type alias Score =
    { base : Base
    , bonus : Bonus
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


toInt : Score -> Int
toInt score =
    score.base * score.bonus



-- VIEW


view : Score -> Html msg
view score =
    div [ class "score" ] [ text (score |> toInt |> toString) ]



-- bonusText =
--     if (word.bonus > 1) then
--         "(x" ++ (toString word.bonus) ++ ") "
--     else
--         ""
