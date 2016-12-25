port module Main exposing (..)

import Board.Board as Board
import Board.Rand as Rand exposing (..)
import Board.Snake as Snake
import Config.Config as Config
import Dom
import GameMode exposing (..)
import Html exposing (..)
import Html exposing (Html, div, button, text)
import Html.Attributes exposing (alt, class, href, id, src, style)
import Json.Decode exposing (decodeValue)
import Json.Encode
import KeyAction exposing (..)
import Keyboard exposing (KeyCode)
import Navigation
import Random.Pcg as Random
import Routing.Routing as Routing exposing (Route(..))
import Routing.Shape as Shape exposing (Shape(..))
import Routing.Token as Token exposing (..)
import Share exposing (..)
import Shuffle exposing (SizeChange)
import Task
import Time exposing (Time)
import Timer exposing (..)
import Util
import Word.Candidate exposing (Status(..))
import Word.Input
import Word.List
import Word.Score as Score
import Window


main : Program Never Model Msg
main =
    Navigation.program UrlChange
        { init = init Config.empty
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { config : Config.Model
    , configError : String
    , board : Board.Model
    , gameMode : GameMode
    , seed : Random.Seed
    , shape : Shape
    , share : Share
    , snake : Snake.Model
    , timer : Timer
    , wordList : Word.List.Model
    }


setSnake : Model -> Snake.Model -> Model
setSnake model =
    \x -> { model | snake = x }


reset : Config.Model -> Model
reset config =
    Model
        config
        ""
        (Board.reset (cellWidth config Shape.default) [])
        Loading
        (Random.initialSeed 0)
        Shape.default
        Share.reset
        Snake.reset
        (Timer.reset Shape.default)
        (Word.List.reset config.apiEndpoint)



-- UPDATE


type Msg
    = BoardMessage Board.Msg
    | FocusResult (Result Dom.Error ())
    | GotoBoard Shape GeneratorVersion Seed
    | KeyDown KeyCode
    | LoadConfig Json.Encode.Value
    | ShareMsg Share.Msg
    | Shuffle SizeChange
    | SnakeMessage Snake.Msg
    | Tick Time
    | UrlChange Navigation.Location
    | WordListMessage Word.List.Msg
    | WindowSize (Result String Window.Size)


init : Config.Model -> Navigation.Location -> ( Model, Cmd Msg )
init config location =
    let
        model =
            reset config

        route =
            Routing.routeFromLocation location
    in
        case route of
            NotFoundRoute ->
                ( { model
                    | shape = Board4x4
                    , gameMode = Playing
                    , timer = Timer.reset Board4x4
                    , board =
                        Board.reset (cellWidth config Board4x4)
                            [ [ '4', 'N', 'F', 'O' ]
                            , [ '0', 'O', 'P', 'U' ]
                            , [ '4', 'T', 'A', 'N' ]
                            , [ 'E', 'G', 'B', 'D' ]
                            ]
                  }
                , Cmd.none
                )

            RandomPlayRoute shape ->
                let
                    gen =
                        Random.int 0 1000000000000
                in
                    ( model, Random.generate (GotoBoard shape 1) gen )

            PlayRoute shape version seedValue ->
                let
                    ( matrix, newSeed ) =
                        Random.initialSeed seedValue
                            |> Random.step (Rand.board config.language shape)
                in
                    ( { model
                        | shape = shape
                        , gameMode = Waiting
                        , timer = Timer.reset shape
                        , board = Board.reset (cellWidth config shape) matrix
                      }
                    , [ Task.attempt FocusResult (Dom.blur "shuffle")
                      , Task.attempt FocusResult (Dom.blur "shuffle-smaller")
                      , Task.attempt FocusResult (Dom.blur "shuffle-bigger")
                      ]
                        |> Cmd.batch
                    )

            ReviewRoute token ->
                refreshWords model.config
                    (updateBoardSize
                        { model
                            | board = token.board
                            , shape = token.shape
                            , wordList = token.words
                            , gameMode = Reviewing
                        }
                    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        BoardMessage cMsg ->
            Board.updateOne BoardMessage cMsg model

        FocusResult error ->
            ( model, Cmd.none )

        GotoBoard shape version seed ->
            ( model, Routing.playUrl shape version seed )

        KeyDown keyCode ->
            case model.gameMode of
                Waiting ->
                    ( { model | gameMode = Playing }, Cmd.none )

                Playing ->
                    keyActionUpdate (actionFromCode keyCode) model

                _ ->
                    ( model, Cmd.none )

        LoadConfig data ->
            let
                result =
                    decodeValue Config.decoder data
            in
                case result of
                    Ok config ->
                        refreshWords config model

                    Err err ->
                        ( { model | configError = err }, Cmd.none )

        ShareMsg shareMsg ->
            Share.updateOne ShareMsg shareMsg model

        Shuffle change ->
            ( model
            , change
                |> Shuffle.changeShape model.shape
                |> Routing.randomPlayUrl
            )

        SnakeMessage cMsg ->
            Snake.updateOne SnakeMessage cMsg model

        Tick time ->
            tick model time

        UrlChange location ->
            init model.config location

        WordListMessage cMsg ->
            case cMsg of
                Word.List.ShowWordPath word ->
                    case model.gameMode of
                        Reviewing ->
                            ( { model
                                | snake = Snake.findSnake model.board.layer word
                              }
                            , Cmd.none
                            )

                        _ ->
                            ( model, Cmd.none )

                _ ->
                    Word.List.updateOne WordListMessage cMsg model

        WindowSize result ->
            case result of
                Ok size ->
                    ( if Config.sizeDidChange size model.config then
                        updateBoardSize
                            { model
                                | config =
                                    Config.setWindowSize
                                        size
                                        model.config
                            }
                      else
                        model
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )


updateBoardSize : Model -> Model
updateBoardSize model =
    { model
        | board =
            Board.setCellWidth
                (cellWidth model.config model.shape)
                model.board
    }


cellWidth : Config.Model -> Shape -> Int
cellWidth conf shape =
    let
        n =
            Shape.toInt shape

        s =
            conf.windowSize

        x =
            (s.width |> toFloat) * 0.7 |> round

        y =
            s.height - 200
    in
        (min x y) // n


refreshWords : Config.Model -> Model -> ( Model, Cmd Msg )
refreshWords config model =
    let
        ( newWordList, cmd ) =
            Word.List.validate
                config.apiEndpoint
                (Snake.findBonus model.board.layer)
                model.wordList
    in
        ( { model
            | config = config
            , wordList = newWordList
          }
        , Cmd.batch
            [ Cmd.map WordListMessage cmd
            , Task.attempt WindowSize Window.size
            ]
        )


tick : Model -> Time -> ( Model, Cmd Msg )
tick model time =
    let
        getSize =
            Task.attempt WindowSize Window.size
    in
        case model.gameMode of
            Playing ->
                let
                    newTimer =
                        Timer.tick model.timer time
                in
                    if Timer.isExpired newTimer then
                        ( { model
                            | timer = Timer.zero
                            , gameMode = Reviewing
                          }
                        , Token
                            model.board
                            model.shape
                            model.wordList
                            |> Routing.reviewUrl FocusResult
                        )
                    else
                        ( { model | timer = newTimer }, getSize )

            _ ->
                ( model, getSize )


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
    [ config LoadConfig
    , Time.every Time.second Tick
    ]
        |> List.append
            (case model.gameMode of
                Waiting ->
                    [ Keyboard.ups KeyDown ]

                Playing ->
                    [ Keyboard.downs KeyDown
                    ]

                _ ->
                    []
            )
        |> Sub.batch



-- VIEW


view : Model -> Html Msg
view model =
    case model.gameMode of
        Loading ->
            h1 [ class "m4" ] [ text "Loading..." ]

        Comparing ->
            h1 [ class "m4" ] [ text "Comparing..." ]

        _ ->
            boardView model


boardView : Model -> Html Msg
boardView model =
    div
        [ class "px2" ]
        [ Shuffle.buttons Shuffle model.shape
        , headerView model
        , div [ class "clearfix" ]
            [ div [ class "col col-3" ] [ Html.map WordListMessage (Word.List.view model.gameMode model.wordList) ]
            , div [ class "rel col col-9 mt3" ]
                [ Html.map BoardMessage (Board.view model.gameMode model.board)
                , Html.map SnakeMessage (Snake.view model.snake)
                ]
            ]
        , Util.forkMe model.config
        ]


headerView : Model -> Html Msg
headerView model =
    let
        timerView =
            Timer.view model.gameMode model.timer
    in
        case model.gameMode of
            Reviewing ->
                Html.map ShareMsg (Share.view model.share timerView)

            _ ->
                Word.Input.view model.gameMode
                    model.snake.word
                    (Snake.bonus model.snake |> Score.newScore model.snake.word)
                    (Word.List.candidateStatus model.wordList model.snake.word)
                    timerView
