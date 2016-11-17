module Routing exposing (..)

import Navigation
import String
import UrlParser exposing (..)
import Room


type Route
    = RandomRoomRoute
    | RoomRoute Room.Id
    | NotFoundRoute


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ format RandomRoomRoute (s "")
        , format RoomRoute (s "room" </> int)
        ]


hashParser : Navigation.Location -> Result String Route
hashParser location =
    location.hash
        |> String.dropLeft 1
        |> parse identity matchers


parser : Navigation.Parser (Result String Route)
parser =
    Navigation.makeParser hashParser


routeFromResult : Result String Route -> Route
routeFromResult result =
    case result of
        Ok route ->
            route

        Err string ->
            NotFoundRoute
