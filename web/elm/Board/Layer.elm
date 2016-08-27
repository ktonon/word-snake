module Board.Layer exposing (..)

import Html exposing (..)
import Html.App
import Board.Cell as Cell


-- MODEL


type alias Model =
    { index : Index
    , cells : List Cell.Model
    }


type alias Index =
    Int


new : Int -> Model
new index =
    Model index []


findCells : Model -> String -> List Cell.Model
findCells layer letter =
    layer.cells
        |> List.filter (\cell -> cell.letter == letter)



-- UPDATE


type Msg
    = CellMessage Cell.Id Cell.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg layer =
    case msg of
        CellMessage id cellMessage ->
            let
                ( newCells, cellCmd ) =
                    layer.cells
                        |> updateCells id cellMessage
            in
                ( { layer | cells = newCells }, Cmd.map (CellMessage id) cellCmd )


updateCells : Cell.Id -> Cell.Msg -> List Cell.Model -> ( List Cell.Model, Cmd Cell.Msg )
updateCells id msg cells =
    let
        ( newCells, cmds ) =
            cells
                |> List.map (updateCell id msg)
                |> List.unzip
    in
        ( newCells, Cmd.batch cmds )


updateCell : Cell.Id -> Cell.Msg -> Cell.Model -> ( Cell.Model, Cmd Cell.Msg )
updateCell id msg cell =
    let
        ( newCell, cmd ) =
            if cell.id == id then
                Cell.update msg cell
            else
                ( cell, Cmd.none )
    in
        ( newCell, cmd )


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
    = ShowLetters
    | ShowPath


view : DisplayType -> Model -> Html Msg
view dtype layer =
    div []
        (layer.cells
            |> List.indexedMap (,)
            |> List.map (cellView dtype)
        )


cellView : DisplayType -> ( Int, Cell.Model ) -> Html Msg
cellView dtype ( index, cell ) =
    let
        cellType =
            case dtype of
                ShowLetters ->
                    Cell.ShowLetter

                ShowPath ->
                    if index == 0 then
                        Cell.HighlightHead
                    else
                        Cell.HighlightTail
    in
        Html.App.map (CellMessage cell.id) (Cell.view cellType cell)


debugView : Model -> Html Msg
debugView layer =
    div [] (List.map debugCellView layer.cells)


debugCellView : Cell.Model -> Html Msg
debugCellView cell =
    Html.App.map (CellMessage cell.id) (Cell.debugView cell)
