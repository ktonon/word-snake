module GameMode exposing (..)

-- MODEL


type GameMode
    = Loading
    | Waiting
    | Playing
    | Reviewing


toString : GameMode -> String
toString gameMode =
    case gameMode of
        Loading ->
            "loading"

        Waiting ->
            "waiting"

        Playing ->
            "playing"

        Reviewing ->
            "reviewing"
