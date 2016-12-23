module Board.Board exposing (..)

import ChildUpdate exposing (updateOne)
import Exts.Json.Decode exposing (parseWith)
import Html exposing (..)
import Board.Cell as Cell
import Board.Layer as Layer
import Json.Encode as J
import Json.Decode as D
import List.Split exposing (chunksOfLeft)


-- MODEL


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



-- SAVE / RESTORE


toJsonValue : Model -> J.Value
toJsonValue model =
    model |> toToken |> J.string


decoder : D.Decoder Model
decoder =
    D.string |> D.andThen (parseWith fromToken)


toToken : Model -> String
toToken =
    .layer >> Layer.toToken


fromToken : String -> Result String Model
fromToken token =
    let
        n =
            token |> String.length

        s =
            n |> toFloat |> sqrt |> round
    in
        if s * s == n then
            Ok
                (token
                    |> String.toList
                    |> chunksOfLeft s
                    |> reset
                )
        else
            Err ("Invalid token: " ++ token)



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


view : Model -> Html Msg
view board =
    div [] [ Html.map LayerMessage (Layer.view Layer.ShowLetters board.layer) ]
