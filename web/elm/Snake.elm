module Snake exposing (..)

import Board.Cell as Cell
import Board.Board as Board exposing (findCells)


type alias Path =
    List Cell.Model


type alias PossibleCells =
    List Cell.Model


type alias PathSet =
    List Path


findPaths : Board.Model -> PathSet -> String -> PathSet
findPaths board pathSet letter =
    let
        cells =
            findCells board letter
    in
        List.concatMap (expandPath cells) pathSet


expandPath : PossibleCells -> Path -> PathSet
expandPath cells path =
    cells
        |> List.map (extendPath path)
        |> List.filter (\p -> not (List.isEmpty p))


extendPath : Path -> Cell.Model -> Path
extendPath path cell =
    if canExtendPath path cell then
        List.append path [ cell ]
    else
        path


canExtendPath : Path -> Cell.Model -> Bool
canExtendPath path cell =
    List.member cell path



-- TODO: check adjacency on canExtendPath
