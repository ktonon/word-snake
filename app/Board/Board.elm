module Board.Board exposing (..)

import Html exposing (..)
import Board.Cell as Cell
import Board.Layer as Layer
import ChildUpdate exposing (updateOne)


-- MODEL


type alias BoardSeed =
    Int


type alias Model =
    { layer : Layer.Model
    }


reset : List (List Char) -> Model
reset grid =
    grid |> initCells |> Layer.Model 0 |> Model


initCells : List (List Char) -> List Cell.Model
initCells grid =
    let
        adj =
            findNeighbours (inBounds ( 0, List.length grid - 1 ))
    in
        grid
            |> List.indexedMap
                (\y letters ->
                    letters |> List.indexedMap (initCell adj y)
                )
            |> List.concat


initCell : (( Int, Int ) -> List String) -> Int -> Int -> Char -> Cell.Model
initCell adj y x letter =
    let
        id =
            (toString x) ++ "_" ++ (toString y)
    in
        adj ( x, y )
            |> Cell.Model id (String.fromChar letter) x y


findNeighbours : (( Int, Int ) -> Maybe String) -> ( Int, Int ) -> List String
findNeighbours neighbour ( x, y ) =
    [ ( x - 1, y - 1 )
    , ( x - 1, y )
    , ( x - 1, y + 1 )
    , ( x, y - 1 )
    , ( x, y + 1 )
    , ( x + 1, y - 1 )
    , ( x + 1, y )
    , ( x + 1, y + 1 )
    ]
        |> List.filterMap neighbour


inBounds : ( Int, Int ) -> ( Int, Int ) -> Maybe String
inBounds ( min, max ) ( x, y ) =
    if x < min || x > max || y < min || y > max then
        Nothing
    else
        (toString x) ++ "_" ++ (toString y) |> Just


findCells : Model -> String -> List Cell.Model
findCells board letter =
    Layer.findCells board.layer letter



-- UPDATE FOR PARENT


type alias HasOne model =
    { model | board : Model }


updateOne : (Msg -> msg) -> Msg -> HasOne m -> ( HasOne m, Cmd msg )
updateOne =
    ChildUpdate.updateOne update .board (\m x -> { m | board = x })



-- UPDATE


type Msg
    = LayerMessage Layer.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg board =
    case msg of
        LayerMessage cMsg ->
            Layer.updateOne LayerMessage cMsg board



-- VIEW


view : Model -> Html Msg
view board =
    div [] [ Html.map LayerMessage (Layer.view Layer.ShowLetters board.layer) ]
