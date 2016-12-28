module Board.Snake exposing (..)

import ChildUpdate
import Html exposing (..)
import Board.Cell as Cell
import Board.Layer as Layer
import String
import Task
import Word.Score exposing (Bonus)


-- MODEL


type alias Model =
    { layers : List Layer.Model
    , undoList : List (List Layer.Model)
    , word : String
    }


setLayers : Model -> List Layer.Model -> Model
setLayers model =
    (\x -> { model | layers = x })


reset : Model
reset =
    Model [] [] ""


bonus : Model -> Int
bonus model =
    List.length model.layers


findSnake : Layer.Model -> String -> Model
findSnake layer word =
    word
        |> String.split ""
        |> List.foldl
            (\letter snake ->
                letter
                    |> Layer.findCells layer
                    |> tryAddCells snake letter
            )
            reset


findBonus : Layer.Model -> String -> Bonus
findBonus layer =
    (findSnake layer) >> bonus



-- UPDATE FOR PARENT


type alias HasOne model =
    { model | snake : Model }


updateOne : (Msg -> msg) -> Msg -> HasOne m -> ( HasOne m, Cmd msg )
updateOne =
    ChildUpdate.updateOne update .snake (\m x -> { m | snake = x })



-- UPDATE


type Msg
    = LayerMessage Layer.Index Layer.Msg
    | CellClicked Cell.Model Cell.DisplayType


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LayerMessage index cMsg ->
            case cMsg of
                Layer.CellClicked cell dtype ->
                    ( model, Task.perform (CellClicked cell) (Task.succeed dtype) )

                _ ->
                    Layer.updateMany LayerMessage index cMsg model

        _ ->
            ( model, Cmd.none )


tryAddCells : Model -> String -> List Cell.Model -> Model
tryAddCells model letter cells =
    let
        layers =
            if List.isEmpty model.layers then
                [ Layer.new 0 ]
            else
                model.layers

        newLayers =
            layers
                |> List.concatMap (Layer.expand cells)
    in
        if Layer.maxLength (newLayers) > Layer.maxLength (model.layers) then
            { model
                | undoList = model.layers :: model.undoList
                , layers =
                    (newLayers
                        |> Layer.keepLongest
                        |> Layer.reIndex
                    )
                , word = model.word ++ letter
            }
        else
            model


undo : Model -> Model
undo model =
    { model
        | layers = model.undoList |> List.head |> Maybe.withDefault []
        , undoList = model.undoList |> List.tail |> Maybe.withDefault []
        , word = model.word |> String.dropRight 1
    }



-- VIEW


view : Model -> Html Msg
view model =
    div [] (List.map viewLayer model.layers)


viewLayer : Layer.Model -> Html Msg
viewLayer layer =
    div [] [ Html.map (LayerMessage layer.index) (Layer.view Layer.ShowPath layer) ]
