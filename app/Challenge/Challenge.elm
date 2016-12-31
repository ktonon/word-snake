module Challenge.Challenge exposing (..)

import Http
import Json.Decode as D exposing (at)
import Json.Encode as J
import Regex exposing (regex, HowMany(..))
import Routing.Shape as Shape exposing (..)
import Task exposing (Task)
import Routing.Token as Token exposing (..)
import UrlParser exposing (..)


type alias Endpoint =
    String


type alias Challenge =
    { id : Id
    , board : String
    , shape : Shape
    , results : List GameResult
    }


type alias Id =
    String


type alias GameResult =
    { player : String
    , score : Int
    , words : List String
    }


type Error
    = HttpError Http.Error
    | Error String


idParser : Parser (Id -> a) a
idParser =
    UrlParser.custom "CHALLENGE_ID"
        (\segment ->
            case parseId segment of
                Just id ->
                    Ok id

                Nothing ->
                    Err ("Bad id: " ++ segment)
        )


parseId : String -> Maybe String
parseId w =
    w
        |> Regex.find (AtMost 1) (regex "^([0-9A-Za-z]{7})$")
        |> List.head
        |> Maybe.andThen
            (\m ->
                m.submatches
                    |> List.head
                    |> Maybe.andThen (\id -> id)
            )



-- API


get : Endpoint -> Id -> Task Error Challenge
get endpoint id =
    Http.get (endpoint ++ "/challenge/" ++ id) challengeDecoder
        |> Http.toTask
        |> Task.mapError HttpError


create : Endpoint -> ( String, Int, Token ) -> Task Error Challenge
create endpoint gameResult =
    Http.request
        { method = "POST"
        , headers = []
        , url = endpoint ++ "/challenge"
        , body = Http.jsonBody (gameResult |> gameResultEncoder)
        , expect = Http.expectJson challengeDecoder
        , timeout = Nothing
        , withCredentials = False
        }
        |> Http.toTask
        |> Task.mapError HttpError


update : Endpoint -> Id -> ( String, Int, Token ) -> Task Error Challenge
update endpoint id gameResult =
    Task.fail (Error "not implemented")



-- ENCODER


gameResultEncoder : ( String, Int, Token ) -> J.Value
gameResultEncoder ( player, score, token ) =
    J.object
        [ ( "player", J.string player )
        , ( "score", J.int score )
        , ( "token", token |> Token.toPathComponent |> J.string )
        ]



-- DECODER


challengeDecoder : D.Decoder Challenge
challengeDecoder =
    D.map4 Challenge
        (at [ "id" ] D.string)
        (at [ "board" ] D.string)
        (at [ "shape" ] Shape.decoder)
        (at [ "results" ] (D.list gameResultDecoder))


gameResultDecoder : D.Decoder GameResult
gameResultDecoder =
    D.map3 GameResult
        (at [ "player" ] D.string)
        (at [ "score" ] D.int)
        (at [ "words" ] (D.list D.string))
