module Board.Board exposing (..)

import GameMode exposing (GameMode(..))
import Html exposing (..)
import Html.Attributes exposing (style)
import Board.Cell as Cell
import Board.Layer as Layer exposing (DisplayType(..))
import List.Split exposing (chunksOfLeft)
import Routing.Shape exposing (Shape(..))


-- MODEL


type alias Model =
    { shape : Shape
    , cellWidth : Int
    , layer : Layer.Model
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
                    |> Model shape cellWidth


initCells : Int -> Shape -> List (List Char) -> List Cell.Model
initCells cellWidth shape grid =
    grid
        |> List.indexedMap
            (\x letters ->
                letters |> List.indexedMap (Cell.init cellWidth shape x)
            )
        |> List.concat


setCellWidth : Int -> Shape -> Model -> Model
setCellWidth w shape model =
    { model
        | layer = model.layer |> Layer.setCellWidth w
        , cellWidth = w
        , shape = shape
    }



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



-- VIEW


view : Cell.Clicked msg -> GameMode -> Model -> Html msg
view clicked gameMode board =
    let
        ( w, h ) =
            case board.shape of
                Shape x y ->
                    ( x * board.cellWidth |> toString
                    , y * board.cellWidth |> toString
                    )

        displayType =
            case gameMode of
                Waiting ->
                    HideLetters

                _ ->
                    ShowLetters
    in
        div
            [ style
                [ ( "width", w ++ "px" )
                , ( "height", h ++ "px" )
                ]
            ]
            [ Layer.view clicked displayType board.layer ]
