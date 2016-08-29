module Main exposing (..)

import Html exposing (Html, div, button, text)
import Html.Events exposing (onClick)
import Html.App
import Html.Attributes exposing (class, style)
import Http
import Json.Decode exposing ((:=))
import Keyboard exposing (KeyCode)
import Navigation
import Random
import String
import Task
import Routing exposing (Route(..))
import Board.Board as Board exposing (BoardSeed)
import Board.Cell as Cell
import ChildUpdate exposing (updateOne)
import KeyAction exposing (..)
import Snake
import WordList


main : Program Never
main =
    Navigation.program Routing.parser
        { init = init
        , update = update
        , view = view
        , urlUpdate = urlUpdate
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { board : Board.Model
    , snake : Snake.Model
    , wordList : WordList.Model
    }


setBoard : Model -> Board.Model -> Model
setBoard model =
    \x -> { model | board = x }


setSnake : Model -> Snake.Model -> Model
setSnake model =
    \x -> { model | snake = x }


setWordList : Model -> WordList.Model -> Model
setWordList model =
    \x -> { model | wordList = x }


empty : Model
empty =
    Model
        (Board.reset [])
        (Snake.reset)
        (WordList.reset)


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
    | KeyDown KeyCode
    | BoardMessage Board.Msg
    | SnakeMessage Snake.Msg
    | WordListMessage WordList.Msg


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

        KeyDown keyCode ->
            keyActionUpdate (actionFromCode keyCode) model

        BoardMessage cMsg ->
            updateOne BoardMessage .board setBoard Board.update cMsg model

        SnakeMessage cMsg ->
            updateOne SnakeMessage .snake setSnake Snake.update cMsg model

        WordListMessage cMsg ->
            updateOne WordListMessage .wordList setWordList WordList.update cMsg model


keyActionUpdate : KeyAction -> Model -> ( Model, Cmd Msg )
keyActionUpdate keyAction model =
    case keyAction of
        Letter letter ->
            ( setSnake model
                (letter
                    |> Board.findCells model.board
                    |> Snake.tryAddCells model.snake letter
                )
            , Cmd.none
            )

        Cancel ->
            ( setSnake model Snake.reset, Cmd.none )

        Commit ->
            let
                word =
                    model.snake.word

                newWordList =
                    if WordList.canAddWord model.wordList word then
                        WordList.Word word (Snake.bonus model.snake)
                            |> WordList.addWord model.wordList
                    else
                        model.wordList
            in
                ( { model
                    | wordList = newWordList
                    , snake = Snake.reset
                  }
                , Cmd.none
                )

        Undo ->
            ( setSnake model (Snake.undo model.snake), Cmd.none )


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



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Keyboard.downs KeyDown



-- VIEW


view : Model -> Html Msg
view model =
    div
        [ class "center"
        , style [ ( "padding", "50px" ) ]
        ]
        [ wordView model.snake
        , div [ class "clearfix" ]
            [ div [ class "right" ] [ Html.App.map WordListMessage (WordList.view model.wordList) ]
            , div [ class "left" ] [ boardView model ]
            ]
        , button
            [ class "btn bg-gray rounded"
            , onClick RandomizeBoard
            ]
            [ text "Shuffle" ]
        ]


boardView : Model -> Html Msg
boardView model =
    div
        [ style
            [ ( "width", "600px" )
            , ( "height", "600px" )
            , ( "position", "relative" )
            ]
        ]
        [ Html.App.map BoardMessage (Board.view model.board)
        , Html.App.map SnakeMessage (Snake.view model.snake)
        ]


wordView : Snake.Model -> Html Msg
wordView snake =
    let
        showWord =
            if String.isEmpty snake.word then
                "Start typing..."
            else
                snake.word

        color =
            if String.isEmpty snake.word then
                "#f8f8f8"
            else
                "#369"
    in
        div []
            [ div
                [ class "center clearfix"
                , style
                    [ ( "font-size", "70px" )
                    , ( "border", "dashed 1px #999" )
                    , ( "border-radius", "20px" )
                    , ( "color", color )
                    ]
                ]
                [ text showWord
                , div [ class "right", style [ ( "padding-right", "20px" ) ] ]
                    (bonusView snake)
                ]
            ]


bonusView : Snake.Model -> List (Html Msg)
bonusView snake =
    let
        bonus =
            Snake.bonus snake
    in
        if bonus > 1 then
            [ text ("x" ++ (toString bonus)) ]
        else
            []
