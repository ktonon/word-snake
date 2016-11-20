module Routing exposing (..)

import Navigation
import UrlParser exposing (..)
import Board.Board exposing (BoardSeed)


type Route
    = RandomBoardRoute
    | BoardRoute BoardSeed


route : Parser (Route -> a) a
route =
    oneOf
        [ map BoardRoute (s "board" </> int)
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
                RandomBoardRoute
