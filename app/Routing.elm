module Routing exposing (..)

import Navigation
import UrlParser exposing (..)
import Room


type Route
    = RandomRoomRoute
    | RoomRoute Room.Id
    | NotFoundRoute


route : Parser (Route -> a) a
route =
    oneOf
        [ map RandomRoomRoute (s "")
        , map RoomRoute (s "room" </> int)
        ]


routeFromLocation : Navigation.Location -> Route
routeFromLocation location =
    let
        maybeRoute =
            parseHash route location
    in
        case maybeRoute of
            Just route ->
                route

            Nothing ->
                NotFoundRoute
