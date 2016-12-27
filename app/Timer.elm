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
    let
        cxn =
            \x y -> x * y

        cxn4 =
            16.0

        time4 =
            3.0 * 60.0

        raw =
            case shape of
                Shape x y ->
                    (time4 * (cxn x y |> toFloat) / cxn4)
    in
        Timer
            0
            0
            (Time.second * (raw / 15 |> round |> toFloat) * 15)


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
                Reviewing ->
                    0

                Comparing ->
                    0

                _ ->
                    (timer.timeAllowed - timer.timeElapsed)
                        / 1000
                        |> round
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
