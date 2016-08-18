module Main exposing (..)

import Html exposing (Html, div, button, text)
import Html.App
import Html.Attributes exposing (class)
import String
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
    let
        letters =
            String.split "" "hello snake"
    in
        ( Model (Board.reset letters), Cmd.none )



-- UPDATE


type Msg
    = NoOp
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



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "center" ]
        [ Html.App.map BoardMessage (Board.view model.board)
        , button [ class "btn bg-gray rounded" ] [ text "Shuffle" ]
        ]
