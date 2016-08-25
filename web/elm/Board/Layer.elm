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
        { layer | cells = List.append layer.cells [ cell ] }
    else
        layer


canExtend : Model -> Cell.Model -> Bool
canExtend layer cell =
    not (List.member cell layer.cells)


reIndex : List Model -> List Model
reIndex layers =
    layers



-- TODO: write reIndex ^^^
-- VIEW


view : Model -> Html Msg
view layer =
    div []
        (List.map cellView layer.cells)


cellView : Cell.Model -> Html Msg
cellView cell =
    Html.App.map (CellMessage cell.id) (Cell.view cell)
