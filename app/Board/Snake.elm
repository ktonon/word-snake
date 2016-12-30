module Board.Snake exposing (..)

import Html exposing (..)
import Board.Cell as Cell
import Board.Layer as Layer
import String
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



-- UPDATE


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


view : Cell.Clicked msg -> Model -> Html msg
view clicked model =
    div [] (List.map (Layer.view clicked Layer.ShowPath) model.layers)
