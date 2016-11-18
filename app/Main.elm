module Main exposing (..)

import Html exposing (Html, div, button, text)
import Navigation
import Random
import Routing exposing (Route(..))
import Room


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
    { room : Room.Model
    }


empty : Model
empty =
    Model
        Room.reset


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    let
        route =
            Routing.routeFromLocation location
    in
        case route of
            RandomRoomRoute ->
                let
                    gen =
                        Random.int 0 1000000000000
                in
                    ( empty, Random.generate GotoRoom gen )

            RoomRoute roomId ->
                ( empty, Cmd.none )

            NotFoundRoute ->
                ( empty, Cmd.none )



-- urlUpdate : Result String Route -> Model -> ( Model, Cmd Msg )
-- urlUpdate result model =
--     init result
-- UPDATE


type Msg
    = RandomizeRoom
    | GotoRoom Room.Id
    | RoomMessage Room.Msg
    | UrlChange Navigation.Location


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RandomizeRoom ->
            ( model, Navigation.newUrl "#" )

        GotoRoom roomId ->
            ( model, Navigation.newUrl ("#room/" ++ toString roomId) )

        RoomMessage cMsg ->
            Room.updateOne RoomMessage cMsg model

        UrlChange location ->
            init location



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map RoomMessage (Room.subscriptions model.room)



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ Html.map RoomMessage (Room.view model.room) ]
