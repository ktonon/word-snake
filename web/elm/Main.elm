module Main exposing (..)

import Html exposing (Html, div, button, text)
import Html.Events exposing (onClick)
import Html.App
import Html.Attributes exposing (class)
import Http
import Json.Decode exposing ((:=))
import Navigation
import Random
import Task
import Routing exposing (Route(..))
import Board exposing (BoardSeed)
import Cell


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
    }


emptyBoard : Model
emptyBoard =
    Model (Board.reset [])


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
                    ( emptyBoard, Random.generate GotoBoard gen )

            BoardRoute boardSeed ->
                ( emptyBoard, fetchBoardInit boardSeed )

            NotFoundRoute ->
                ( Model (Board.reset []), Cmd.none )


urlUpdate : Result String Route -> Model -> ( Model, Cmd Msg )
urlUpdate result model =
    init result



-- UPDATE


type Msg
    = NoOp
    | RandomizeBoard
    | GotoBoard BoardSeed
    | FetchBoardInit BoardSeed
    | FetchBoardInitOk (List Cell.Model)
    | FetchBoardInitFailed Http.Error
    | BoardMessage Board.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        BoardMessage boardMessage ->
            let
                ( newBoard, boardCmd ) =
                    Board.update boardMessage model.board
            in
                ( { model | board = newBoard }, Cmd.map BoardMessage boardCmd )

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


fetchBoardInit : BoardSeed -> Cmd Msg
fetchBoardInit boardSeed =
    Http.get boardInit ("/api/boards/" ++ toString boardSeed)
        |> Task.perform FetchBoardInitFailed FetchBoardInitOk


boardInit : Json.Decode.Decoder (List Cell.Model)
boardInit =
    "cells"
        := (Json.Decode.list
                (Json.Decode.object5 Cell.Model
                    ("letter" := Json.Decode.string)
                    ("x" := Json.Decode.int)
                    ("y" := Json.Decode.int)
                    ("id" := Json.Decode.string)
                    ("adj" := (Json.Decode.list Json.Decode.string))
                )
           )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ Html.App.map BoardMessage (Board.view model.board)
        , button
            [ class "btn bg-gray rounded"
            , onClick RandomizeBoard
            ]
            [ text "Shuffle" ]
        ]
