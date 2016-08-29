module Board.Layer exposing (..)

import Html exposing (..)
import Html.App
import Board.Cell as Cell
import ChildUpdate exposing (updateMany)


-- MODEL


type alias Model =
    { index : Index
    , cells : List Cell.Model
    }


type alias Index =
    Int


setCells : Model -> List Cell.Model -> Model
setCells model =
    (\x -> { model | cells = x })


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
        CellMessage id cMsg ->
            updateMany CellMessage .cells setCells .id Cell.update id cMsg layer


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
