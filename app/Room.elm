module Room exposing (..)

import ChildUpdate
import Html exposing (..)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)
import Http
import Keyboard exposing (KeyCode)
import Random.Pcg as Random
import String
import Board.Board as Board exposing (BoardSeed)
import Board.Cell as Cell
import KeyAction exposing (..)
import Rand exposing (Lang(..), Size(..))
import Snake
import WordList


-- MODEL


type alias Id =
    Int


type alias Model =
    { board : Board.Model
    , id : Id
    , snake : Snake.Model
    , wordList : WordList.Model
    , tempLetters : List (List Char)
    }


setSnake : Model -> Snake.Model -> Model
setSnake model =
    \x -> { model | snake = x }


reset : Model
reset =
    Model
        (Board.reset [])
        -1
        Snake.reset
        WordList.reset
        []



-- UPDATE FOR PARENT


type alias HasOne model =
    { model | room : Model }


updateOne : (Msg -> msg) -> Msg -> HasOne m -> ( HasOne m, Cmd msg )
updateOne =
    ChildUpdate.updateOne update .room (\m x -> { m | room = x })



-- UPDATE


type Msg
    = NoOp
    | Shuffle
    | NewBoardLetters (List (List Char))
    | FetchBoardInit BoardSeed
    | FetchBoardInitOk (List Cell.Model)
    | FetchBoardInitFailed Http.Error
    | RandomizeBoard
    | KeyDown KeyCode
    | BoardMessage Board.Msg
    | SnakeMessage Snake.Msg
    | WordListMessage WordList.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Shuffle ->
            ( model
            , Random.generate NewBoardLetters
                (Rand.board English Board5x5)
            )

        NewBoardLetters matrix ->
            ( { model | tempLetters = matrix }, Cmd.none )

        FetchBoardInit boardSeed ->
            ( model, Cmd.none )

        -- ( model, fetchBoardInit boardSeed )
        FetchBoardInitOk init ->
            ( { model | board = Board.reset init }, Cmd.none )

        FetchBoardInitFailed _ ->
            ( model, Cmd.none )

        RandomizeBoard ->
            let
                gen =
                    Random.int 0 1000000000000
            in
                ( model, Random.generate FetchBoardInit gen )

        KeyDown keyCode ->
            keyActionUpdate (actionFromCode keyCode) model

        BoardMessage cMsg ->
            Board.updateOne BoardMessage cMsg model

        SnakeMessage cMsg ->
            Snake.updateOne SnakeMessage cMsg model

        WordListMessage cMsg ->
            WordList.updateOne WordListMessage cMsg model



-- fetchBoardInit : BoardSeed -> Cmd Msg
-- fetchBoardInit boardSeed =
--     Http.get boardInit ("/api/boards/" ++ toString boardSeed)
-- |> Task.perform FetchBoardInitFailed FetchBoardInitOk
-- boardInit : Json.Decode.Decoder (List Cell.Model)
-- boardInit =
--     (Json.Decode.field "cells"
--         (Json.Decode.list
--             (Json.Decode.map5 Cell.Model
--                 (Json.Decode.field "id" Json.Decode.string)
--                 (Json.Decode.field "letter" Json.Decode.string)
--                 (Json.Decode.field "x" Json.Decode.int)
--                 (Json.Decode.field "y" Json.Decode.int)
--                 (Json.Decode.field "adj" (Json.Decode.list Json.Decode.string))
--             )
--         )
--     )


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



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Keyboard.downs KeyDown



-- VIEW


view : Model -> Html Msg
view room =
    div
        [ class "center"
        , style [ ( "padding", "50px" ) ]
        ]
        [ wordView room.snake
        , div [ class "clearfix" ]
            [ div [ class "right" ] [ Html.map WordListMessage (WordList.view room.wordList) ]
            , div [ class "left" ] [ boardView room ]
            ]
        , button
            [ class "btn bg-gray rounded"
            , onClick Shuffle
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
        [ Html.map BoardMessage (Board.view model.board)
        , Html.map SnakeMessage (Snake.view model.snake)
        , tempLettersView model.tempLetters
        ]


tempLettersView : List (List Char) -> Html Msg
tempLettersView cols =
    div [] (List.map colView cols)


colView : List Char -> Html Msg
colView col =
    div []
        (List.map
            (\char -> char |> String.fromChar |> text)
            col
        )


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
