port module Main exposing (..)

import Board.Board as Board exposing (BoardSeed)
import Config
import Dom
import Html exposing (..)
import Html exposing (Html, div, button, text)
import Html.Attributes exposing (class, style, id)
import Html.Events exposing (onClick)
import Json.Decode exposing (decodeValue)
import Json.Encode
import KeyAction exposing (..)
import Keyboard exposing (KeyCode)
import Navigation
import Rand exposing (Lang(..), Size(..))
import Random.Pcg as Random
import Routing exposing (Route(..))
import Board.Snake as Snake
import Task
import Word.Candidate exposing (Status(..))
import Word.Input
import Word.List
import Word.Score as Score


main : Program Never Model Msg
main =
    Navigation.program UrlChange
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { seed : Random.Seed
    , board : Board.Model
    , snake : Snake.Model
    , wordList : Word.List.Model
    }


setSnake : Model -> Snake.Model -> Model
setSnake model =
    \x -> { model | snake = x }


reset : Model
reset =
    Model
        (Random.initialSeed 0)
        (Board.reset [])
        Snake.reset
        (Word.List.reset "")



-- UPDATE


type Msg
    = LoadConfig Json.Encode.Value
    | BoardMessage Board.Msg
    | FocusResult (Result Dom.Error ())
    | GotoBoard Board.BoardSeed
    | KeyDown KeyCode
    | Shuffle
    | SnakeMessage Snake.Msg
    | UrlChange Navigation.Location
    | WordListMessage Word.List.Msg


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    let
        route =
            Routing.routeFromLocation location
    in
        case route of
            RandomBoardRoute ->
                let
                    gen =
                        Random.int 0 1000000000000
                in
                    ( reset, Random.generate GotoBoard gen )

            BoardRoute val ->
                let
                    seed =
                        Random.initialSeed val

                    ( matrix, newSeed ) =
                        Random.step (Rand.board English Board4x4) seed
                in
                    ( { reset | board = Board.reset matrix }
                    , Task.attempt FocusResult (Dom.blur "shuffle")
                    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadConfig data ->
            let
                result =
                    decodeValue Config.decoder data
            in
                case result of
                    Ok config ->
                        ( { model | wordList = Word.List.reset config.apiEndpoint }, Cmd.none )

                    Err err ->
                        ( model, Cmd.none )

        BoardMessage cMsg ->
            Board.updateOne BoardMessage cMsg model

        FocusResult error ->
            ( model, Cmd.none )

        GotoBoard boardSeed ->
            ( model, Navigation.newUrl ("#board/" ++ toString boardSeed) )

        KeyDown keyCode ->
            keyActionUpdate (actionFromCode keyCode) model

        Shuffle ->
            ( model, Navigation.newUrl "#" )

        SnakeMessage cMsg ->
            Snake.updateOne SnakeMessage cMsg model

        UrlChange location ->
            init location

        WordListMessage cMsg ->
            Word.List.updateOne WordListMessage cMsg model


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

                ( newWordList, cmd ) =
                    case Word.List.candidateStatus model.wordList word of
                        Good ->
                            Word.List.addWord model.wordList word (Snake.bonus model.snake)

                        _ ->
                            ( model.wordList, Cmd.none )
            in
                ( { model
                    | wordList = newWordList
                    , snake = Snake.reset
                  }
                , Cmd.map WordListMessage cmd
                )

        Undo ->
            ( setSnake model (Snake.undo model.snake), Cmd.none )



-- SUBSCRIPTIONS


port config : (Json.Encode.Value -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Keyboard.downs KeyDown
        , config LoadConfig
        ]



-- VIEW


view : Model -> Html Msg
view model =
    div
        [ style [ ( "padding", "50px" ) ]
        ]
        [ Word.Input.view model.snake.word
            (Snake.bonus model.snake |> Score.newScore model.snake.word)
            (Word.List.candidateStatus model.wordList model.snake.word)
        , div [ class "clearfix" ]
            [ div [ class "col col-9" ] [ boardView model ]
            , div [] [ Html.map WordListMessage (Word.List.view model.wordList) ]
            ]
        , button
            [ class "btn bg-gray rounded"
            , id "shuffle"
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
        ]
