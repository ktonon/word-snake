module Board.Rand
    exposing
        ( board
        , Seed
        )

import Config.Lang as Lang exposing (..)
import Random.Extra exposing (combine, constant, frequency)
import Random exposing (..)
import Routing.Shape as Shape exposing (..)


type alias Seed =
    Int



-- GENERATOR


board : Lang -> Shape -> Generator (List Char)
board lang =
    case lang of
        English ->
            boardWithSize englishLetter


boardWithSize : Generator Char -> Shape -> Generator (List Char)
boardWithSize genChar size =
    case size of
        Shape x y ->
            if x >= 0 && y >= 0 then
                List.range 1 (x * y)
                    |> List.foldl (\_ list -> genChar :: list) []
                    |> combine
            else
                constant []


englishLetter : Generator Char
englishLetter =
    frequency
        [ ( 0.1202, constant 'E' )
        , ( 0.091, constant 'T' )
        , ( 0.0812, constant 'A' )
        , ( 0.0768, constant 'O' )
        , ( 0.0731, constant 'I' )
        , ( 0.0695, constant 'N' )
        , ( 0.0628, constant 'S' )
        , ( 0.0602, constant 'R' )
        , ( 0.0592, constant 'H' )
        , ( 0.0432, constant 'D' )
        , ( 0.0398, constant 'L' )
        , ( 0.0288, constant 'U' )
        , ( 0.0271, constant 'C' )
        , ( 0.0261, constant 'M' )
        , ( 0.023, constant 'F' )
        , ( 0.0211, constant 'Y' )
        , ( 0.0209, constant 'W' )
        , ( 0.0203, constant 'G' )
        , ( 0.0182, constant 'P' )
        , ( 0.0149, constant 'B' )
        , ( 0.0111, constant 'V' )
        , ( 0.0069, constant 'K' )
        , ( 0.0017, constant 'X' )
        , ( 0.0011, constant 'Q' )
        , ( 0.001, constant 'J' )
        , ( 0.0007, constant 'Z' )
        ]
