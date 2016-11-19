module Rand exposing (board, Lang(..), Size(..))

import Random.Pcg exposing (..)


type Lang
    = English


type Size
    = Board3x3
    | Board4x4
    | Board5x5


board : Lang -> Size -> Generator (List (List Char))
board lang =
    case lang of
        English ->
            boardWithSize englishLetter


boardWithSize : Generator Char -> Size -> Generator (List (List Char))
boardWithSize genChar size =
    case size of
        Board3x3 ->
            board3x3 genChar

        Board4x4 ->
            board4x4 genChar

        Board5x5 ->
            board5x5 genChar


board3x3 : Generator Char -> Generator (List (List Char))
board3x3 genChar =
    map3 three (column3 genChar) (column3 genChar) (column3 genChar)


board4x4 : Generator Char -> Generator (List (List Char))
board4x4 genChar =
    map4 four (column4 genChar) (column4 genChar) (column4 genChar) (column4 genChar)


board5x5 : Generator Char -> Generator (List (List Char))
board5x5 genChar =
    map5 five (column5 genChar) (column5 genChar) (column5 genChar) (column5 genChar) (column5 genChar)


column3 : Generator Char -> Generator (List Char)
column3 genChar =
    map3 three genChar genChar genChar


column4 : Generator Char -> Generator (List Char)
column4 genChar =
    map4 four genChar genChar genChar genChar


column5 : Generator Char -> Generator (List Char)
column5 genChar =
    map5 five genChar genChar genChar genChar genChar


three : a -> a -> a -> List a
three a b c =
    [ a, b, c ]


four : a -> a -> a -> a -> List a
four a b c d =
    [ a, b, c, d ]


five : a -> a -> a -> a -> a -> List a
five a b c d e =
    [ a, b, c, d, e ]


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
