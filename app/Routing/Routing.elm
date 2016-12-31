module Routing.Routing exposing (..)

import Board.Rand as Rand exposing (..)
import Challenge.Challenge as Challenge exposing (..)
import Dom
import Navigation
import Routing.Shape as Shape exposing (..)
import Routing.Token as Token exposing (..)
import Task
import UrlParser exposing (..)


type Route
    = NotFoundRoute
    | RandomPlayRoute Shape
    | PlayRoute Shape Seed
    | ReviewRoute Token
    | ChallengeRoute Challenge.Id


randomPlayUrl : Shape -> Cmd msg
randomPlayUrl shape =
    "#play/"
        ++ (Shape.toPathComponent shape)
        |> Navigation.newUrl


playUrl : Shape -> Seed -> Cmd msg
playUrl shape seed =
    "#play/"
        ++ (Shape.toPathComponent shape)
        ++ "/"
        ++ (toString seed)
        |> Navigation.newUrl


reviewUrl : (Result Dom.Error () -> msg) -> Token -> Cmd msg
reviewUrl focusHandler token =
    Cmd.batch
        [ "#review/"
            ++ (token |> Token.toPathComponent)
            |> Navigation.newUrl
        , Task.attempt focusHandler (Dom.focus "username")
        ]


challengeUrl : Challenge.Id -> Cmd msg
challengeUrl id =
    "#play/"
        ++ id
        |> Navigation.newUrl


route : Parser (Route -> a) a
route =
    oneOf
        [ map ChallengeRoute (s "play" </> Challenge.idParser)
        , map PlayRoute (s "play" </> Shape.parser </> int)
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
