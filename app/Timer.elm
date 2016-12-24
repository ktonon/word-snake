module Timer exposing (..)

import GameMode exposing (GameMode(..))
import Html exposing (..)
import Html.Attributes exposing (class)
import Routing.Shape as Shape exposing (Shape(..))
import Time exposing (Time)


-- MODEL


type alias Timer =
    { startTime : Time
    , timeElapsed : Time
    , timeAllowed : Time
    }


reset : Shape -> Timer
reset shape =
    Timer
        0
        0
        (case shape of
            Board3x3 ->
                Time.second * 45

            Board4x4 ->
                Time.minute * 3

            Board5x5 ->
                Time.minute * 5
        )


zero : Timer
zero =
    Timer 0 0 0


isExpired : Timer -> Bool
isExpired timer =
    timer.timeElapsed >= timer.timeAllowed



-- UPDATE


tick : Timer -> Time -> Timer
tick timer time =
    let
        start =
            if timer.startTime == 0 then
                time
            else
                timer.startTime
    in
        { timer
            | startTime = start
            , timeElapsed = time - start
        }



-- VIEW


view : GameMode -> Timer -> Html msg
view gameMode timer =
    let
        t =
            case gameMode of
                Playing ->
                    (timer.timeAllowed - timer.timeElapsed)
                        / 1000
                        |> round

                _ ->
                    0
    in
        div [ class ("timer " ++ (gameMode |> GameMode.toString)) ]
            [ timeRemainingText t ]


timeRemainingText : Int -> Html msg
timeRemainingText t =
    let
        min =
            t // 60

        sec =
            t % 60
    in
        text
            ((toString min)
                ++ ":"
                ++ (if sec < 10 then
                        "0"
                    else
                        ""
                   )
                ++ (toString sec)
            )
