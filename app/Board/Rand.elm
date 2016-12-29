module Board.Rand
    exposing
        ( board
        , Seed
        )

import Board.EngPair exposing (englishPair)
import Config.Lang as Lang exposing (..)
import Random.Extra exposing (combine, constant, frequency)
import Random exposing (..)
import Routing.Shape as Shape exposing (..)


type alias Seed =
    Int



-- GENERATOR


type alias Freq =
    ( Int, Char )


type alias FreqList =
    List Freq


board : Lang -> Shape -> Random.Seed -> ( List Char, Random.Seed )
board lang shape seed =
    case lang of
        English ->
            boardWithSize englishPair shape seed


boardWithSize : (Char -> FreqList) -> Shape -> Random.Seed -> ( List Char, Random.Seed )
boardWithSize pair shape seed =
    case shape of
        Shape x y ->
            if x >= 0 && y >= 0 then
                List.range 1 (x * y)
                    |> List.foldl (nextLetter pair y) ( [], seed )
            else
                ( [], seed )


nextLetter : (Char -> FreqList) -> Int -> Int -> ( List Char, Random.Seed ) -> ( List Char, Random.Seed )
nextLetter pair y _ ( chars, seed ) =
    let
        ( weights, letterSeed ) =
            Random.step
                (Random.map4 (\a b c d -> [ a, b, c, d ])
                    (Random.int 0 100)
                    (Random.int 0 100)
                    (Random.int 0 100)
                    (Random.int 0 100)
                )
                seed

        ( char, newSeed ) =
            Random.step (pairFreq pair y chars weights) letterSeed
    in
        ( char :: chars, newSeed )


pairFreq : (Char -> FreqList) -> Int -> List Char -> List Int -> Generator Char
pairFreq pair y chars weights =
    chars
        |> List.indexedMap (,)
        |> List.filter (isNeighbour y (chars |> List.length))
        |> List.map Tuple.second
        |> List.map pair
        |> List.map2 (,) weights
        |> List.foldl sumFreq []
        |> (\list ->
                if List.isEmpty list then
                    pair '.'
                else
                    list
           )
        |> List.map (\( x, letter ) -> ( x |> toFloat, constant letter ))
        |> frequency


isNeighbour : Int -> Int -> Freq -> Bool
isNeighbour y n ( j, letter ) =
    let
        i =
            n - 1 - j

        r =
            n % y
    in
        (i == n - 1 && r /= 0)
            || (i == n - y)
            || (i == n - y - 1 && r /= 0)
            || (i == n - y + 1 && r /= y - 1)


sumFreq : ( Int, FreqList ) -> FreqList -> FreqList
sumFreq ( weight, freq ) totalFreq =
    if List.isEmpty totalFreq then
        freq
    else
        List.map2 (addFreq weight) freq totalFreq


addFreq : Int -> Freq -> Freq -> Freq
addFreq weight ( freq, a ) ( totalFreq, b ) =
    ( freq * weight + totalFreq, a )
