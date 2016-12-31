module Routing.Shape exposing (..)

import Json.Decode as D
import List.Extra exposing (getAt)
import Regex exposing (regex, HowMany(..))
import Toolkit.Helpers exposing (maybe2Tuple)
import UrlParser exposing (..)


-- MODEL


type Shape
    = Shape Int Int


smallest : Int
smallest =
    3


largest : Int
largest =
    9


default : Shape
default =
    Shape 5 5


toWidth : Shape -> Int
toWidth shape =
    case shape of
        Shape width _ ->
            width


toHeight : Shape -> Int
toHeight shape =
    case shape of
        Shape _ height ->
            height


toPathComponent : Shape -> String
toPathComponent shape =
    case shape of
        Shape x y ->
            (x |> toString) ++ "x" ++ (y |> toString)


parser : Parser (Shape -> a) a
parser =
    UrlParser.custom "SHAPE"
        (\segment ->
            case parseInt2Tuple segment of
                Just ( x, y ) ->
                    Ok (Shape x y)

                Nothing ->
                    Err ("Bad shape: " ++ segment)
        )


decoder : D.Decoder Shape
decoder =
    D.string
        |> D.andThen
            (\w ->
                case parseInt2Tuple w of
                    Just ( x, y ) ->
                        D.succeed (Shape x y)

                    Nothing ->
                        D.fail ("Bad shape: " ++ w)
            )


parseInt2Tuple : String -> Maybe ( Int, Int )
parseInt2Tuple w =
    w
        |> Regex.find (AtMost 1) (regex "^(\\d+)x(\\d+)$")
        |> List.head
        |> Maybe.andThen
            (\m ->
                ( m.submatches
                    |> List.head
                    |> Maybe.andThen (\x -> x |> Maybe.andThen (String.toInt >> Result.toMaybe))
                , m.submatches
                    |> getAt 1
                    |> Maybe.andThen (\x -> x |> Maybe.andThen (String.toInt >> Result.toMaybe))
                )
                    |> maybe2Tuple
            )
