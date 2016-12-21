module Routing.Routing exposing (..)

import Board.Rand as Rand exposing (..)
import Navigation
import Routing.Lang as Lang exposing (..)
import Routing.Shape as Shape exposing (..)
import UrlParser exposing (..)


type Route
    = NotFoundRoute
    | RandomPlayRoute Lang Shape
    | PlayRoute Lang Shape GeneratorVersion Seed


randomPlayUrl : Lang -> Shape -> Cmd msg
randomPlayUrl lang shape =
    "#play/"
        ++ (Lang.toPathComponent lang)
        ++ "/"
        ++ (Shape.toPathComponent shape)
        |> Navigation.newUrl


playUrl : Lang -> Shape -> GeneratorVersion -> Seed -> Cmd msg
playUrl lang shape version seed =
    "#play/"
        ++ (Lang.toPathComponent lang)
        ++ "/"
        ++ (Shape.toPathComponent shape)
        ++ "/"
        ++ (toString version)
        ++ "/"
        ++ (toString seed)
        |> Navigation.newUrl


route : Parser (Route -> a) a
route =
    oneOf
        [ map PlayRoute (s "play" </> Lang.parser </> Shape.parser </> int </> int)
        , map RandomPlayRoute (s "play" </> Lang.parser </> Shape.parser)
        , map (Shape.default |> flip RandomPlayRoute) (s "play" </> Lang.parser)
        , map (RandomPlayRoute Lang.default Shape.default) (s "play")
        , map (RandomPlayRoute Lang.default Shape.default) UrlParser.top
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
