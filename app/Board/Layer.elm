module Board.Layer exposing (..)

import Board.Cell as Cell
import ChildUpdate
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



-- UPDATE FOR PARENT


type alias HasOne model =
    { model | layer : Model }


type alias HasMany model =
    { model | layers : List Model }


updateOne : (Msg -> msg) -> Msg -> HasOne m -> ( HasOne m, Cmd msg )
updateOne =
    ChildUpdate.updateOne update .layer (\m x -> { m | layer = x })


updateMany : (Index -> Msg -> msg) -> Index -> Msg -> HasMany m -> ( HasMany m, Cmd msg )
updateMany =
    ChildUpdate.updateMany update .index .layers (\m x -> { m | layers = x })



-- UPDATE


type Msg
    = CellMessage Cell.Id Cell.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg layer =
    case msg of
        CellMessage id cMsg ->
            Cell.updateMany CellMessage id cMsg layer


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
        Html.map (CellMessage cell.id) (Cell.view cellType cell)
