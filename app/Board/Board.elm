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
        bounds =
            ( 0, List.length grid - 1 )
    in
        grid
            |> List.indexedMap
                (\x letters ->
                    letters |> List.indexedMap (Cell.init bounds x)
                )
            |> List.concat


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
