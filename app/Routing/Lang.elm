module Routing.Lang exposing (..)

import UrlParser exposing (Parser, oneOf, s)


-- MODEL


type Lang
    = English


default : Lang
default =
    English


toPathComponent : Lang -> String
toPathComponent lang =
    case lang of
        English ->
            "en"


parser : Parser (Lang -> a) a
parser =
    oneOf [ UrlParser.map English (s "en") ]
