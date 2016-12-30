port module Main exposing (..)

import Board.Board as Board
import Board.Cell as Cell
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
import Random as Random
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
        (Board.reset Shape.default (cellWidth config Shape.default) [])
        Loading
        (Random.initialSeed 0)
        Shape.default
        Share.reset
        Snake.reset
        (Timer.reset Shape.default)
        (Word.List.reset config.apiEndpoint)



-- UPDATE


type Msg
    = CellClicked Cell.Model Cell.DisplayType
    | FocusResult (Result Dom.Error ())
    | GotoBoard Shape Seed
    | KeyDown KeyCode
    | LoadConfig Json.Encode.Value
    | ShareMsg Share.Msg
    | Shuffle SizeChange
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
                let
                    s =
                        Shape 4 4
                in
                    ( { model
                        | shape = s
                        , gameMode = Playing
                        , timer = Timer.reset s
                        , board =
                            Board.reset s
                                (cellWidth config s)
                                ("4NFO0PU4TANEGBD" |> String.toList)
                      }
                    , Cmd.none
                    )

            RandomPlayRoute shape ->
                let
                    gen =
                        Random.int 0 1000000000000
                in
                    ( model, Random.generate (GotoBoard shape) gen )

            PlayRoute shape seedValue ->
                let
                    ( matrix, newSeed ) =
                        Random.initialSeed seedValue
                            |> Rand.board config.language shape
                in
                    ( { model
                        | shape = shape
                        , gameMode = Waiting
                        , timer = Timer.reset shape
                        , board = Board.reset shape (cellWidth config shape) matrix
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
                            | board = Board.fromToken token.shape token.board
                            , shape = token.shape
                            , wordList = token.words
                            , gameMode = Reviewing
                        }
                    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CellClicked cell displayType ->
            case displayType of
                Cell.HideLetter ->
                    ( { model | gameMode = Playing }, Cmd.none )

                Cell.ShowLetter ->
                    ( tryAddCell model cell, Cmd.none )

                Cell.HighlightHead ->
                    commitWord model

                Cell.HighlightTail ->
                    ( { model | snake = Snake.reset }, Cmd.none )

        FocusResult error ->
            ( model, Cmd.none )

        GotoBoard shape seed ->
            ( model, Routing.playUrl shape seed )

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
                model.shape
                model.board
    }


boardSize : Config.Model -> ( Int, Int )
boardSize conf =
    let
        s =
            conf.windowSize
    in
        if conf.isMobile then
            ( (s.width |> toFloat) * 0.9 |> round, s.height - 100 )
        else
            ( (s.width |> toFloat) * 0.58 |> round, s.height - 200 )


cellWidth : Config.Model -> Shape -> Int
cellWidth conf shape =
    let
        ( x, y ) =
            boardSize conf
    in
        (min (x // Shape.toWidth shape)
            (y // Shape.toHeight shape)
        )


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
                            (model.board |> Board.toToken)
                            model.shape
                            model.wordList
                            |> Routing.reviewUrl FocusResult
                        )
                    else
                        ( { model | timer = newTimer }, getSize )

            _ ->
                ( model, getSize )


tryAddCell : Model -> Cell.Model -> Model
tryAddCell model cell =
    case model.gameMode of
        Waiting ->
            { model | gameMode = Playing }

        Playing ->
            setSnake model
                (Snake.tryAddCells model.snake cell.letter [ cell ])

        _ ->
            model


commitWord : Model -> ( Model, Cmd Msg )
commitWord model =
    let
        word =
            model.snake.word

        ( newWordList, cmd ) =
            case Word.List.candidateStatus model.wordList word of
                Good ->
                    Word.List.addWord model.wordList word (Snake.findBonus model.board.layer word)

                _ ->
                    ( model.wordList, Cmd.none )
    in
        ( { model
            | wordList = newWordList
            , snake = Snake.reset
          }
        , Cmd.map WordListMessage cmd
        )


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
            commitWord model

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
    div
        [ class
            (if model.config.isMobile then
                "mobile"
             else
                ""
            )
        ]
        [ case model.gameMode of
            Loading ->
                h1 [ class "m4" ] [ text "Loading..." ]

            Comparing ->
                h1 [ class "m4" ] [ text "Comparing..." ]

            _ ->
                boardView model
        ]


boardView : Model -> Html Msg
boardView model =
    let
        board =
            [ Board.view CellClicked model.gameMode model.board
            , Snake.view CellClicked model.snake
            ]

        shuffle =
            Shuffle.buttons Shuffle model.shape

        timer =
            Timer.view model.gameMode model.timer

        wordList =
            [ Html.map WordListMessage (Word.List.view model.gameMode model.wordList) ]
    in
        div
            [ class "px2" ]
            [ if model.config.isMobile then
                div [ class "clearfix" ]
                    [ div [ class "col col-5" ] [ timer ]
                    , div [ class "col col-7" ] [ shuffle ]
                    ]
              else
                shuffle
            , Html.map ShareMsg (headerView model timer)
            , div [ class "clearfix" ]
                (if model.config.isMobile then
                    [ div [ class "rel mt3" ] board
                    , div [] wordList
                    ]
                 else
                    [ div [ class "col col-5" ] wordList
                    , div [ class "rel col col-7 mt3" ] board
                    ]
                )
            , Util.forkMe model.config
            ]


headerView : Model -> Html Share.Msg -> Html Share.Msg
headerView model timerView =
    case model.gameMode of
        Reviewing ->
            Share.view model.config.isMobile model.share timerView

        _ ->
            if model.config.isMobile then
                span [] []
            else
                Word.Input.view model.gameMode
                    model.snake.word
                    (Snake.bonus model.snake |> Score.newScore model.snake.word)
                    (Word.List.candidateStatus model.wordList model.snake.word)
                    timerView
