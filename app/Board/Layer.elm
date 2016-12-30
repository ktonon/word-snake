module Board.Layer exposing (..)

import Board.Cell as Cell
import Html exposing (..)


-- MODEL


type alias Model =
    { index : Index
    , cells : List Cell.Model
    }


type alias Index =
    Int


toToken : Model -> String
toToken layer =
    layer.cells
        |> List.map .letter
        |> String.join ""


new : Int -> Model
new index =
    Model index []


findCells : Model -> String -> List Cell.Model
findCells layer letter =
    layer.cells
        |> List.filter (\cell -> cell.letter == letter)


setCellWidth : Int -> Model -> Model
setCellWidth w layer =
    { layer | cells = layer.cells |> List.map (Cell.setWidth w) }



-- UPDATE


expand : List Cell.Model -> Model -> List Model
expand cells layer =
    cells
        |> List.map (extend layer)
        |> List.filter (\l -> not (List.isEmpty l.cells))


extend : Model -> Cell.Model -> Model
extend layer cell =
    if canExtend layer cell then
        { layer | cells = cell :: layer.cells }
    else
        layer


canExtend : Model -> Cell.Model -> Bool
canExtend layer cell =
    not (List.member cell layer.cells)
        && (Cell.isAdjacent cell (List.head layer.cells))


maxLength : List Model -> Int
maxLength layers =
    let
        maxLengthMaybe =
            layers
                |> List.map (\l -> List.length l.cells)
                |> List.maximum
    in
        case maxLengthMaybe of
            Just maxLength ->
                maxLength

            Nothing ->
                0


keepLongest : List Model -> List Model
keepLongest layers =
    let
        maxLengthMaybe =
            layers
                |> List.map (\l -> List.length l.cells)
                |> List.maximum
    in
        case maxLengthMaybe of
            Just maxLength ->
                layers
                    |> List.filter
                        (\l ->
                            (List.length l.cells) == maxLength
                        )

            Nothing ->
                []


reIndex : List Model -> List Model
reIndex layers =
    layers



-- TODO: write reIndex ^^^
-- VIEW


type DisplayType
    = HideLetters
    | ShowLetters
    | ShowPath


view : Cell.Clicked msg -> DisplayType -> Model -> Html msg
view clicked dtype layer =
    div []
        (layer.cells
            |> List.indexedMap (,)
            |> List.map (cellView clicked dtype)
        )


cellView : Cell.Clicked msg -> DisplayType -> ( Int, Cell.Model ) -> Html msg
cellView clicked dtype ( index, cell ) =
    let
        cellType =
            case dtype of
                HideLetters ->
                    Cell.HideLetter

                ShowLetters ->
                    Cell.ShowLetter

                ShowPath ->
                    if index == 0 then
                        Cell.HighlightHead
                    else
                        Cell.HighlightTail
    in
        Cell.view clicked cellType cell
