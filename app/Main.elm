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
import Shuffle exposing (SizeChange)
import Task
import Time exposing (Time)
import Timer exposing (..)
import Util
import Word.Candidate exposing (Status(..))
import Word.Input
import Word.List
import Word.Score as Score


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
    = Playing
    | Reviewing
    | Loading


setSnake : Model -> Snake.Model -> Model
setSnake model =
    \x -> { model | snake = x }


reset : Config.Model -> Model
reset config =
    Model
        config
        ""
        (Board.reset [])
        Loading
        (Random.initialSeed 0)
        Shape.default
        Snake.reset
        (Timer.reset Shape.default)
        (Word.List.reset "")



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
                        Board.reset
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
                        , board = Board.reset matrix
                      }
                    , [ Task.attempt FocusResult (Dom.blur "shuffle")
                      , Task.attempt FocusResult (Dom.blur "shuffle-smaller")
                      , Task.attempt FocusResult (Dom.blur "shuffle-bigger")
                      ]
                        |> Cmd.batch
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
            keyActionUpdate (actionFromCode keyCode) model

        LoadConfig data ->
            let
                result =
                    decodeValue Config.decoder data
            in
                case result of
                    Ok config ->
                        ( { model
                            | config = config
                            , wordList = Word.List.reset config.apiEndpoint
                          }
                        , Cmd.none
                        )

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
            ( tick model time, Cmd.none )

        UrlChange location ->
            init model.config location

        WordListMessage cMsg ->
            Word.List.updateOne WordListMessage cMsg model


tick : Model -> Time -> Model
tick model time =
    case model.mode of
        Playing ->
            let
                newTimer =
                    Timer.tick model.timer time
            in
                if Timer.isExpired newTimer then
                    { model | timer = Timer.zero, mode = Reviewing }
                else
                    { model | timer = newTimer }

        _ ->
            model


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
    case model.mode of
        Playing ->
            Sub.batch
                [ Keyboard.downs KeyDown
                , Time.every Time.second Tick
                , config LoadConfig
                ]

        _ ->
            config LoadConfig



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
            [ div [ class "col col-9" ] [ boardView model ]
            , Html.map WordListMessage (Word.List.view model.wordList)
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
        cssLength =
            (shape |> Shape.toInt |> \n -> n * 150 |> toString) ++ "px"
    in
        style
            [ ( "width", cssLength )
            , ( "height", cssLength )
            , ( "position", "relative" )
            ]
