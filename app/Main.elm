port module Main exposing (..)

import Board.Board as Board
import Board.Rand as Rand exposing (..)
import Board.Snake as Snake
import Config.Config as Config
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
import Random.Pcg as Random
import Routing.Routing as Routing exposing (Route(..))
import Routing.Shape as Shape exposing (Shape(..))
import Task
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
    , shape : Shape
    , seed : Random.Seed
    , board : Board.Model
    , snake : Snake.Model
    , wordList : Word.List.Model
    }


type SizeChange
    = Smaller
    | Same
    | Bigger


setSnake : Model -> Snake.Model -> Model
setSnake model =
    \x -> { model | snake = x }


reset : Config.Model -> Model
reset config =
    Model
        config
        Shape.default
        (Random.initialSeed 0)
        (Board.reset [])
        Snake.reset
        (Word.List.reset "")



-- UPDATE


type Msg
    = LoadConfig Json.Encode.Value
    | BoardMessage Board.Msg
    | FocusResult (Result Dom.Error ())
    | GotoBoard Shape GeneratorVersion Seed
    | KeyDown KeyCode
    | Shuffle SizeChange
    | SnakeMessage Snake.Msg
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
                ( model, Cmd.none )

            RandomPlayRoute shape ->
                let
                    gen =
                        Random.int 0 1000000000000
                in
                    ( model, Random.generate (GotoBoard shape 1) gen )

            PlayRoute shape version seedValue ->
                let
                    seed =
                        Random.initialSeed seedValue

                    ( matrix, newSeed ) =
                        Random.step (Rand.board config.language shape) seed
                in
                    ( { model
                        | shape = shape
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

        GotoBoard shape version seed ->
            ( model, Routing.playUrl shape version seed )

        KeyDown keyCode ->
            keyActionUpdate (actionFromCode keyCode) model

        Shuffle sizeChange ->
            let
                s =
                    newShape model.shape sizeChange
            in
                ( model, Routing.randomPlayUrl s )

        SnakeMessage cMsg ->
            Snake.updateOne SnakeMessage cMsg model

        UrlChange location ->
            init model.config location

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
        [ class "px2" ]
        [ shuffleButtons model.shape
        , Word.Input.view model.snake.word
            (Snake.bonus model.snake |> Score.newScore model.snake.word)
            (Word.List.candidateStatus model.wordList model.snake.word)
        , div [ class "clearfix" ]
            [ div [ class "col col-9" ] [ boardView model ]
            , div [] [ Html.map WordListMessage (Word.List.view model.wordList) ]
            ]
        ]


shuffleButtons : Shape -> Html Msg
shuffleButtons shape =
    let
        ( showSmaller, showBigger ) =
            case shape of
                Board3x3 ->
                    ( False, True )

                Board5x5 ->
                    ( True, False )

                _ ->
                    ( True, True )
    in
        div [ class "center py2" ]
            [ shuffleButton "shuffle-smaller" "" "fa fa-th-large" Smaller showSmaller
            , shuffleButton "shuffle" "Shuffle" "" Same True
            , shuffleButton "shuffle-bigger" "" "fa fa-th" Bigger showBigger
            ]


shuffleButton : String -> String -> String -> SizeChange -> Bool -> Html Msg
shuffleButton id_ label icon sizeChange show =
    if show then
        a
            [ class ("shuffle m1 " ++ icon)
            , id id_
            , onClick (Shuffle sizeChange)
            ]
            [ text label ]
    else
        span [ class ("shuffle disabled m1 " ++ icon) ] [ text label ]


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
            Shape.toInt shape

        cssLength =
            (n * 150 |> toString) ++ "px"
    in
        style
            [ ( "width", cssLength )
            , ( "height", cssLength )
            , ( "position", "relative" )
            ]


newShape : Shape -> SizeChange -> Shape
newShape shape sizeChange =
    case ( shape, sizeChange ) of
        ( Board3x3, Bigger ) ->
            Board4x4

        ( Board4x4, Smaller ) ->
            Board3x3

        ( Board4x4, Bigger ) ->
            Board5x5

        ( Board5x5, Smaller ) ->
            Board4x4

        ( board, _ ) ->
            board
