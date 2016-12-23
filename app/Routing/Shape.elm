module Routing.Shape exposing (..)

import Json.Decode as D
import UrlParser exposing (Parser, oneOf, s)


-- MODEL


type Shape
    = Board3x3
    | Board4x4
    | Board5x5


default : Shape
default =
    Board4x4


toInt : Shape -> Int
toInt shape =
    case shape of
        Board3x3 ->
            3

        Board4x4 ->
            4

        Board5x5 ->
            5


toPathComponent : Shape -> String
toPathComponent shape =
    case shape of
        Board3x3 ->
            "3x3"

        Board4x4 ->
            "4x4"

        Board5x5 ->
            "5x5"


parser : Parser (Shape -> a) a
parser =
    oneOf
        [ UrlParser.map Board3x3 (s "3x3")
        , UrlParser.map Board4x4 (s "4x4")
        , UrlParser.map Board5x5 (s "5x5")
        ]


decoder : D.Decoder Shape
decoder =
    D.string
        |> D.andThen
            (\w ->
                case w of
                    "3x3" ->
                        D.succeed Board3x3

                    "4x4" ->
                        D.succeed Board4x4

                    "5x5" ->
                        D.succeed Board5x5

                    _ ->
                        D.fail ("bad shape: " ++ w)
            )
