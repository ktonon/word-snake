module Routing.Token exposing (..)

import Base64
import Board.Board as Board
import Json.Encode as J
import Json.Decode as D exposing (at)
import Result
import Routing.Shape as Shape exposing (..)
import UrlParser exposing (Parser, custom)
import Word.List


-- MODEL


type alias Token =
    { board : Board.Model
    , shape : Shape
    , words : Word.List.Model
    }


toPathComponent : Token -> String
toPathComponent token =
    case
        J.object
            [ ( "b", Board.toJsonValue token.board )
            , ( "s", J.string (token.shape |> Shape.toPathComponent) )
            , ( "w", Word.List.toJsonValue token.words )
            ]
            |> J.encode 0
            |> Base64.encode
    of
        Ok pc ->
            pc

        _ ->
            "error"


decoder : D.Decoder Token
decoder =
    D.map3 Token
        (at [ "b" ] Board.decoder)
        (at [ "s" ] Shape.decoder)
        (at [ "w" ] Word.List.decoder)


parser : Parser (Token -> a) a
parser =
    custom "foo"
        (\b64EncodedString ->
            b64EncodedString
                |> Base64.decode
                |> (Result.andThen
                        (D.decodeString decoder)
                   )
        )
