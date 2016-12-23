module Routing.Routing exposing (..)

import Board.Rand as Rand exposing (..)
import Navigation
import Routing.Shape as Shape exposing (..)
import Routing.Token as Token exposing (..)
import UrlParser exposing (..)


type Route
    = NotFoundRoute
    | RandomPlayRoute Shape
    | PlayRoute Shape GeneratorVersion Seed
    | ReviewRoute Token


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


reviewUrl : Token -> Cmd msg
reviewUrl token =
    "#review/"
        ++ (token |> Token.toPathComponent)
        |> Navigation.newUrl


route : Parser (Route -> a) a
route =
    oneOf
        [ map PlayRoute (s "play" </> Shape.parser </> int </> int)
        , map RandomPlayRoute (s "play" </> Shape.parser)
        , map (RandomPlayRoute Shape.default) (s "play")
        , map (RandomPlayRoute Shape.default) UrlParser.top
        , map ReviewRoute (s "review" </> Token.parser)
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
