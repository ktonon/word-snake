module Main exposing (..)

import Html exposing (Html, div, button, text)
import Html.App
import Html.Attributes exposing (class)
import Http
import Json.Decode exposing ((:=))
import Task
import Board


main : Program Never
main =
    Html.App.program
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }



-- MODEL


type alias Model =
    { board : Board.Model
    }


init : ( Model, Cmd Msg )
init =
    ( Model (Board.reset []), fetchBoardInit )



-- UPDATE


type Msg
    = NoOp
    | FetchBoardInit
    | FetchBoardInitOk (List String)
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

        FetchBoardInit ->
            ( model, fetchBoardInit )

        FetchBoardInitOk init ->
            ( { model | board = Board.reset init }, Cmd.none )

        FetchBoardInitFailed _ ->
            ( model, Cmd.none )


fetchBoardInit : Cmd Msg
fetchBoardInit =
    Http.get boardInit "/api/boards/123"
        |> Task.perform FetchBoardInitFailed FetchBoardInitOk


boardInit : Json.Decode.Decoder (List String)
boardInit =
    "cells" := (Json.Decode.list (Json.Decode.string))



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "center" ]
        [ Html.App.map BoardMessage (Board.view model.board)
        , button [ class "btn bg-gray rounded" ] [ text "Shuffle" ]
        ]
