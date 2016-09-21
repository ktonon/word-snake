module Main exposing (..)

import Html exposing (Html, div, button, text)
import Html.App
import Navigation
import Random
import Routing exposing (Route(..))
import Room


main : Program Never
main =
    Navigation.program Routing.parser
        { init = init
        , update = update
        , view = view
        , urlUpdate = urlUpdate
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { room : Room.Model
    }


empty : Model
empty =
    Model
        Room.reset


init : Result String Route -> ( Model, Cmd Msg )
init result =
    let
        route =
            Routing.routeFromResult result
    in
        case route of
            RandomRoomRoute ->
                let
                    gen =
                        Random.int 0 1000000000000
                in
                    ( empty, Random.generate GotoRoom gen )

            RoomRoute roomId ->
                ( empty, Cmd.map RoomMessage (Room.fetchBoardInit 0) )

            NotFoundRoute ->
                ( empty, Cmd.none )


urlUpdate : Result String Route -> Model -> ( Model, Cmd Msg )
urlUpdate result model =
    init result



-- UPDATE


type Msg
    = RandomizeRoom
    | GotoRoom Room.Id
    | RoomMessage Room.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RandomizeRoom ->
            ( model, Navigation.newUrl "#" )

        GotoRoom roomId ->
            ( model, Navigation.newUrl ("#room/" ++ toString roomId) )

        RoomMessage cMsg ->
            Room.updateOne RoomMessage cMsg model



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map RoomMessage (Room.subscriptions model.room)



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ Html.App.map RoomMessage (Room.view model.room) ]
