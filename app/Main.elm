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
import Snake
import String
import Task
import WordList


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
    , wordList : WordList.Model
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
        (WordList.reset "")



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
    | WordListMessage WordList.Msg


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
                        Random.step (Rand.board English Board5x5) seed
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
                        ( { model | wordList = WordList.reset config.apiEndpoint }, Cmd.none )

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
            WordList.updateOne WordListMessage cMsg model


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
                    if WordList.canAddWord model.wordList word then
                        WordList.Word word (Snake.bonus model.snake) Nothing
                            |> WordList.addWord model.wordList
                    else
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
        [ class "center"
        , style [ ( "padding", "50px" ) ]
        ]
        [ wordView model.snake
        , div [ class "clearfix" ]
            [ div [ class "right" ] [ Html.map WordListMessage (WordList.view model.wordList) ]
            , div [ class "left" ] [ boardView model ]
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
            [ ( "width", "750px" )
            , ( "height", "750px" )
            , ( "position", "relative" )
            ]
        ]
        [ Html.map BoardMessage (Board.view model.board)
        , Html.map SnakeMessage (Snake.view model.snake)
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
