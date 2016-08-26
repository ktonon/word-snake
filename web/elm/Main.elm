module Main exposing (..)

import Html exposing (Html, div, button, text)
import Html.Events exposing (onClick)
import Html.App
import Html.Attributes exposing (class, style)
import Http
import Json.Decode exposing ((:=))
import Navigation
import Random
import Task
import Routing exposing (Route(..))
import Board.Board as Board exposing (BoardSeed)
import Board.Cell as Cell
import Snake


main : Program Never
main =
    Navigation.program Routing.parser
        { init = init
        , update = update
        , view = view
        , urlUpdate = urlUpdate
        , subscriptions = \_ -> Sub.none
        }



-- MODEL


type alias Model =
    { board : Board.Model
    , snake : Snake.Model
    }


empty : Model
empty =
    Model (Board.reset []) (Snake.reset)


init : Result String Route -> ( Model, Cmd Msg )
init result =
    let
        route =
            Routing.routeFromResult result
    in
        case route of
            RandomBoardRoute ->
                let
                    gen =
                        Random.int 0 1000000000000
                in
                    ( empty, Random.generate GotoBoard gen )

            BoardRoute boardSeed ->
                ( empty, fetchBoardInit boardSeed )

            NotFoundRoute ->
                ( empty, Cmd.none )


urlUpdate : Result String Route -> Model -> ( Model, Cmd Msg )
urlUpdate result model =
    init result



-- UPDATE


type Msg
    = RandomizeBoard
    | GotoBoard BoardSeed
    | FetchBoardInit BoardSeed
    | FetchBoardInitOk (List Cell.Model)
    | FetchBoardInitFailed Http.Error
    | BoardMessage Board.Msg
    | SnakeMessage Snake.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RandomizeBoard ->
            ( model, Navigation.newUrl "#" )

        GotoBoard boardSeed ->
            ( model, Navigation.newUrl ("#board/" ++ toString boardSeed) )

        FetchBoardInit boardSeed ->
            ( model, fetchBoardInit boardSeed )

        FetchBoardInitOk init ->
            ( { model | board = Board.reset init }, Cmd.none )

        FetchBoardInitFailed _ ->
            ( model, Cmd.none )

        BoardMessage boardMessage ->
            let
                ( newBoard, boardCmd ) =
                    Board.update boardMessage model.board
            in
                ( { model | board = newBoard }, Cmd.map BoardMessage boardCmd )

        SnakeMessage snakeMessage ->
            let
                ( newSnake, snakeCmd ) =
                    Snake.update snakeMessage model.snake
            in
                ( { model | snake = newSnake }, Cmd.map SnakeMessage snakeCmd )


fetchBoardInit : BoardSeed -> Cmd Msg
fetchBoardInit boardSeed =
    Http.get boardInit ("/api/boards/" ++ toString boardSeed)
        |> Task.perform FetchBoardInitFailed FetchBoardInitOk


boardInit : Json.Decode.Decoder (List Cell.Model)
boardInit =
    "cells"
        := (Json.Decode.list
                (Json.Decode.object5 Cell.Model
                    ("id" := Json.Decode.string)
                    ("letter" := Json.Decode.string)
                    ("x" := Json.Decode.int)
                    ("y" := Json.Decode.int)
                    ("adj" := (Json.Decode.list Json.Decode.string))
                )
           )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ div
            [ class "center"
            , style
                [ ( "width", "600px" )
                , ( "height", "600px" )
                , ( "position", "relative" )
                ]
            ]
            [ Html.App.map BoardMessage (Board.view model.board)
            , Html.App.map SnakeMessage (Snake.view model.snake)
            ]
        , button
            [ class "btn bg-gray rounded"
            , onClick RandomizeBoard
            ]
            [ text "Shuffle" ]
        ]
