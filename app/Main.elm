port module Main exposing (..)

import Board.Board as Board
import Board.Rand as Rand exposing (..)
import Board.Snake as Snake
import Config.Config as Config
import Dom
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
    , mode : Mode
    , seed : Random.Seed
    , shape : Shape
    , snake : Snake.Model
    , timer : Timer
    , wordList : Word.List.Model
    }


type Mode
    = Loading
    | Playing
    | Reviewing
    | Comparing


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
    | Shuffle SizeChange
    | SnakeMessage Snake.Msg
    | Tick Time
    | UrlChange Navigation.Location
    | WordListMessage Word.List.Msg
    | WindowSizeGet (Result String Window.Size)


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
                    , mode = Playing
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
                        , mode = Playing
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
                    { model
                        | board = token.board
                        , shape = token.shape
                        , wordList = token.words
                        , mode = Reviewing
                    }


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
            keyActionUpdate (actionFromCode keyCode) model

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
            Word.List.updateOne WordListMessage cMsg model

        WindowSizeGet result ->
            case result of
                Ok size ->
                    let
                        newConfig =
                            Config.setWindowSize size model.config
                    in
                        ( { model
                            | config = newConfig
                            , board = Board.setCellWidth (cellWidth newConfig model.shape) model.board
                          }
                        , Cmd.none
                        )

                _ ->
                    ( model, Cmd.none )


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
            , Task.attempt WindowSizeGet Window.size
            ]
        )


tick : Model -> Time -> ( Model, Cmd Msg )
tick model time =
    let
        getSize =
            Task.attempt WindowSizeGet Window.size
    in
        case model.mode of
            Playing ->
                let
                    newTimer =
                        Timer.tick model.timer time
                in
                    if Timer.isExpired newTimer then
                        ( { model | timer = Timer.zero, mode = Reviewing }
                        , Token
                            model.board
                            model.shape
                            model.wordList
                            |> Routing.reviewUrl
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
            (case model.mode of
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
    case model.mode of
        Loading ->
            h1 [ class "m4" ] [ text "Loading..." ]

        Playing ->
            playingView model

        Reviewing ->
            playingView model

        Comparing ->
            h1 [ class "m4" ] [ text "Comparing..." ]


playingView : Model -> Html Msg
playingView model =
    div
        [ class "px2" ]
        [ Shuffle.buttons Shuffle model.shape
        , Word.Input.view model.snake.word
            (Snake.bonus model.snake |> Score.newScore model.snake.word)
            (Word.List.candidateStatus model.wordList model.snake.word)
            (Timer.view model.timer)
        , div [ class "clearfix" ]
            [ div [ class "col col-3" ] [ Html.map WordListMessage (Word.List.view model.wordList) ]
            , div [ class "col col-9 mt3" ] [ boardView model ]
            ]
        , Util.forkMe model.config
        ]


boardView : Model -> Html Msg
boardView model =
    div
        [ boardStyle model.shape ]
        [ Html.map BoardMessage (Board.view model.board)
        , Html.map SnakeMessage (Snake.view model.snake)
        ]


boardStyle : Shape -> Html.Attribute msg
boardStyle shape =
    let
        n =
            shape |> Shape.toInt |> \n -> n * 150

        cssLength =
            (\n -> (n |> toString) ++ "px")
    in
        style
            [ ( "width", n |> cssLength )
            , ( "height", n |> cssLength )
            , ( "position", "relative" )
            ]
