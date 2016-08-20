module Board exposing (..)

import Html exposing (..)
import Html.App
import Html.Attributes exposing (class, style)
import Cell


-- MODEL


type alias BoardSeed =
    Int


type alias Model =
    { cells : List CellRef
    }


type alias CellRef =
    { index : Int
    , cell : Cell.Model
    }


reset : List Cell.Model -> Model
reset cells =
    let
        refs =
            cells
                |> List.indexedMap CellRef
    in
        Model refs



-- UPDATE


type Msg
    = NoOp
    | CellMessage Int Cell.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg board =
    case msg of
        NoOp ->
            ( board, Cmd.none )

        CellMessage index cellMessage ->
            let
                ( newRefs, cellCmd ) =
                    board.cells
                        |> updateCellRefs index cellMessage
            in
                ( { board | cells = newRefs }, Cmd.map (CellMessage index) cellCmd )


updateCellRefs : Int -> Cell.Msg -> List CellRef -> ( List CellRef, Cmd Cell.Msg )
updateCellRefs index msg refs =
    let
        ( newRefs, cmds ) =
            refs
                |> List.map (updateCellRef index msg)
                |> List.unzip
    in
        ( newRefs, Cmd.batch cmds )


updateCellRef : Int -> Cell.Msg -> CellRef -> ( CellRef, Cmd Cell.Msg )
updateCellRef index msg ref =
    let
        ( cell, cmd ) =
            if ref.index == index then
                Cell.update msg ref.cell
            else
                ( ref.cell, Cmd.none )
    in
        ( CellRef ref.index cell, cmd )



-- VIEW


view : Model -> Html Msg
view board =
    div
        [ class "center"
        , style
            [ ( "width", "600px" )
            , ( "height", "600px" )
            , ( "position", "relative" )
            ]
        ]
        (List.map viewRef board.cells)


viewRef : CellRef -> Html Msg
viewRef ref =
    Html.App.map (CellMessage ref.index) (Cell.view ref.cell)
