module Snake exposing (..)

import Html exposing (..)
import Html.App
import Html.Attributes exposing (..)
import Board.Cell as Cell
import Board.Layer as Layer


-- MODEL


type alias Model =
    { layers : List Layer.Model
    }


reset : Model
reset =
    Model []



-- UPDATE


type Msg
    = LayerMessage Layer.Index Layer.Msg
    | TryAddCells (List Cell.Model)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LayerMessage index layerMessage ->
            let
                ( newLayers, layerCmd ) =
                    model.layers
                        |> updateLayers index layerMessage
            in
                ( { model | layers = newLayers }, Cmd.map (LayerMessage index) layerCmd )

        TryAddCells cells ->
            ( tryAddCells model cells, Cmd.none )


updateLayers : Layer.Index -> Layer.Msg -> List Layer.Model -> ( List Layer.Model, Cmd Layer.Msg )
updateLayers index msg layers =
    let
        ( newLayers, cmds ) =
            layers
                |> List.map (updateLayer index msg)
                |> List.unzip
    in
        ( newLayers, Cmd.batch cmds )


updateLayer : Layer.Index -> Layer.Msg -> Layer.Model -> ( Layer.Model, Cmd Layer.Msg )
updateLayer index msg layer =
    let
        ( newLayer, cmd ) =
            if layer.index == index then
                Layer.update msg layer
            else
                ( layer, Cmd.none )
    in
        ( newLayer, cmd )


tryAddCells : Model -> List Cell.Model -> Model
tryAddCells model cells =
    let
        newLayers =
            model.layers
                |> List.concatMap (Layer.expand cells)
                |> Layer.reIndex
    in
        { model | layers = newLayers }



-- TODO: check adjacency on canExtendPath
-- VIEW


view : Model -> Html Msg
view model =
    div [] (List.map viewLayer model.layers)


viewLayer : Layer.Model -> Html Msg
viewLayer layer =
    div [] [ Html.App.map (LayerMessage layer.index) (Layer.view "white bg-blue" layer) ]


debugView : Model -> Html Msg
debugView model =
    div []
        ((text ("snakes: " ++ (model.layers |> List.length |> toString)))
            :: (List.map debugViewLayer model.layers)
        )


debugViewLayer : Layer.Model -> Html Msg
debugViewLayer layer =
    div []
        [ Html.App.map (LayerMessage layer.index) (Layer.debugView layer)
        ]
