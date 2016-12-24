module GameMode exposing (..)

-- MODEL


type GameMode
    = Loading
    | Playing
    | Reviewing
    | Comparing


toString : GameMode -> String
toString gameMode =
    case gameMode of
        Loading ->
            "loading"

        Playing ->
            "playing"

        Reviewing ->
            "reviewing"

        Comparing ->
            "comparing"
