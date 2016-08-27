module Board.Board exposing (..)

import Html exposing (..)
import Html.App
import Html.Attributes exposing (class, style)
import Board.Cell as Cell
import Board.Layer as Layer


-- MODEL


type alias BoardSeed =
    Int


type alias Model =
    { layer : Layer.Model
    }


reset : List Cell.Model -> Model
reset cells =
    Model (Layer.Model 0 cells)


findCells : Model -> String -> List Cell.Model
findCells board letter =
    Layer.findCells board.layer letter



-- UPDATE


type Msg
    = LayerMessage Layer.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg board =
    case msg of
        LayerMessage layerMessage ->
            let
                ( newLayer, layerCmd ) =
                    Layer.update layerMessage board.layer
            in
                ( { board | layer = newLayer }, Cmd.map LayerMessage layerCmd )



-- VIEW


view : Model -> Html Msg
view board =
    div [] [ Html.App.map LayerMessage (Layer.view Layer.ShowLetters board.layer) ]
