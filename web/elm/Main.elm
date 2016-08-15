module Main exposing (..)

import Html exposing (Html, div, button, text)
import Html.App
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Cell


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
    { cell : Cell.Model
    }


init : ( Model, Cmd Msg )
init =
    update Shuffle (Model Cell.init)



-- UPDATE


type Msg
    = Shuffle
    | A Cell.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Shuffle ->
            let
                ( _, cellCmd ) =
                    Cell.update Cell.Shuffle model.cell
            in
                ( model, Cmd.map A cellCmd )

        A cellMsg ->
            let
                ( cellModel, _ ) =
                    Cell.update cellMsg model.cell
            in
                ( { model | cell = cellModel }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "center" ]
        [ Html.App.map A (Cell.view model.cell)
        , button [ class "btn bg-gray rounded", onClick Shuffle ] [ text "Shuffle" ]
        ]
