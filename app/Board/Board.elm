module Board.Board exposing (..)

import ChildUpdate exposing (updateOne)
import GameMode exposing (GameMode(..))
import Html exposing (..)
import Board.Cell as Cell
import Board.Layer as Layer exposing (DisplayType(..))
import List.Split exposing (chunksOfLeft)
import Routing.Shape exposing (Shape(..))


-- MODEL


type alias Model =
    { layer : Layer.Model
    }


defaultCellWidth : Int
defaultCellWidth =
    150


reset : Shape -> Int -> List Char -> Model
reset shape cellWidth grid =
    let
        columns =
            List.length grid
    in
        case shape of
            Shape _ y ->
                grid
                    |> chunksOfLeft y
                    |> initCells cellWidth shape
                    |> Layer.Model 0
                    |> Model


initCells : Int -> Shape -> List (List Char) -> List Cell.Model
initCells cellWidth shape grid =
    grid
        |> List.indexedMap
            (\x letters ->
                letters |> List.indexedMap (Cell.init cellWidth shape x)
            )
        |> List.concat


setCellWidth : Int -> Model -> Model
setCellWidth w model =
    { model | layer = model.layer |> Layer.setCellWidth w }



-- SAVE / RESTORE


toToken : Model -> String
toToken =
    .layer >> Layer.toToken


fromToken : Shape -> String -> Model
fromToken shape token =
    token
        |> String.toList
        |> reset shape defaultCellWidth



-- QUERY


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


view : GameMode -> Model -> Html Msg
view gameMode board =
    let
        displayType =
            case gameMode of
                Waiting ->
                    HideLetters

                _ ->
                    ShowLetters
    in
        div [] [ Html.map LayerMessage (Layer.view displayType board.layer) ]
