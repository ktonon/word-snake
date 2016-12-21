module Routing.Routing exposing (..)

import Board.Rand as Rand exposing (..)
import Navigation
import Routing.Shape as Shape exposing (..)
import UrlParser exposing (..)


type Route
    = NotFoundRoute
    | RandomPlayRoute Shape
    | PlayRoute Shape GeneratorVersion Seed


randomPlayUrl : Shape -> Cmd msg
randomPlayUrl shape =
    "#play/"
        ++ (Shape.toPathComponent shape)
        |> Navigation.newUrl


playUrl : Shape -> GeneratorVersion -> Seed -> Cmd msg
playUrl shape version seed =
    "#play/"
        ++ (Shape.toPathComponent shape)
        ++ "/"
        ++ (toString version)
        ++ "/"
        ++ (toString seed)
        |> Navigation.newUrl


route : Parser (Route -> a) a
route =
    oneOf
        [ map PlayRoute (s "play" </> Shape.parser </> int </> int)
        , map RandomPlayRoute (s "play" </> Shape.parser)
        , map (RandomPlayRoute Shape.default) (s "play")
        , map (RandomPlayRoute Shape.default) UrlParser.top
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
