module Config.Lang exposing (..)

import Json.Decode exposing (..)


-- MODEL


type Lang
    = English


default : Lang
default =
    English


decoder : Decoder Lang
decoder =
    string
        |> andThen
            (\w ->
                case w of
                    "en" ->
                        succeed English

                    _ ->
                        succeed default
            )
