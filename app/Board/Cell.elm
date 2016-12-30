module Board.Cell exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)
import Routing.Shape exposing (Shape(..))


-- MODEL


type alias Model =
    { id : Id
    , letter : String
    , x : Int
    , y : Int
    , width : Int
    , adj : List Id
    }


type alias Id =
    String


type alias Pos =
    ( Int, Int )


setWidth : Int -> Model -> Model
setWidth w cell =
    { cell | width = w }


makeId : Pos -> Id
makeId ( x, y ) =
    (toString x) ++ "_" ++ (toString y)


init : Int -> Shape -> Int -> Int -> Char -> Model
init width shape x y letter =
    let
        pos =
            ( x, y )
    in
        findNeighbours shape pos
            |> Model (makeId pos) (String.fromChar letter) x y width


findNeighbours : Shape -> Pos -> List Id
findNeighbours shape ( x, y ) =
    [ ( x - 1, y - 1 )
    , ( x - 1, y )
    , ( x - 1, y + 1 )
    , ( x, y - 1 )
    , ( x, y + 1 )
    , ( x + 1, y - 1 )
    , ( x + 1, y )
    , ( x + 1, y + 1 )
    ]
        |> List.filterMap (inBoundId shape)


inBoundId : Shape -> Pos -> Maybe Id
inBoundId shape ( x, y ) =
    case shape of
        Shape xMax yMax ->
            if x < 0 || x > xMax || y < 0 || y > yMax then
                Nothing
            else
                makeId ( x, y ) |> Just



-- UPDATE


isAdjacent : Model -> Maybe Model -> Bool
isAdjacent cell maybeOther =
    case maybeOther of
        Nothing ->
            True

        Just other ->
            List.member cell.id other.adj



-- VIEW


type DisplayType
    = HideLetter
    | ShowLetter
    | HighlightHead
    | HighlightTail


type alias Clicked msg =
    Model -> DisplayType -> msg


view : Clicked msg -> DisplayType -> Model -> Html msg
view clickedMsg dtype cell =
    let
        letter =
            case dtype of
                HideLetter ->
                    ""

                _ ->
                    cell.letter
    in
        div
            [ Html.Attributes.type_ "button"
            , class ("cell " ++ customClass dtype)
            , onClick (clickedMsg cell dtype)
            , style (commonStyle cell)
            ]
            [ text letter ]


commonStyle : Model -> List ( String, String )
commonStyle cell =
    let
        spacing =
            2
    in
        [ ( "left", (toString (cell.x * cell.width)) ++ "px" )
        , ( "top", (toString (cell.y * cell.width)) ++ "px" )
        , ( "font-size", (toString ((cell.width |> toFloat) * 0.7 |> round)) ++ "px" )
        , ( "width", (toString (cell.width - spacing)) ++ "px" )
        , ( "height", (toString (cell.width - spacing)) ++ "px" )
        ]


customClass : DisplayType -> String
customClass dtype =
    case dtype of
        HideLetter ->
            "hide-letter fa fa-question-circle"

        ShowLetter ->
            "show-letter"

        HighlightTail ->
            "highlight-tail"

        HighlightHead ->
            "highlight-head"
