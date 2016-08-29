module Snake exposing (..)

import Html exposing (..)
import Html.App
import Html.Attributes exposing (..)
import String
import Board.Cell as Cell
import Board.Layer as Layer
import ChildUpdate exposing (updateMany)


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



-- UPDATE


type Msg
    = LayerMessage Layer.Index Layer.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LayerMessage index cMsg ->
            updateMany LayerMessage .layers setLayers .index Layer.update index cMsg model


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
    div [] [ Html.App.map (LayerMessage layer.index) (Layer.view Layer.ShowPath layer) ]
