module Routing exposing (..)

import Navigation
import String
import UrlParser exposing (..)
import Board exposing (BoardSeed)


type Route
    = RandomBoardRoute
    | BoardRoute BoardSeed
    | NotFoundRoute


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ format RandomBoardRoute (s "")
        , format BoardRoute (s "board" </> int)
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
