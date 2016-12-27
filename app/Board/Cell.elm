module Board.Cell exposing (..)

import ChildUpdate
import Html exposing (..)
import Html.Attributes exposing (class, style)
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



-- UPDATE FOR PARENT


type alias HasMany model =
    { model | cells : List Model }


updateMany : (Id -> Msg -> msg) -> Id -> Msg -> HasMany m -> ( HasMany m, Cmd msg )
updateMany =
    ChildUpdate.updateMany update .id .cells (\m x -> { m | cells = x })



-- UPDATE


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg cell =
    case msg of
        NoOp ->
            ( cell, Cmd.none )


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


view : DisplayType -> Model -> Html Msg
view dtype cell =
    let
        ( letter, icon ) =
            case dtype of
                HideLetter ->
                    ( "", " fa fa-question-circle" )

                _ ->
                    ( cell.letter, "" )
    in
        button
            [ class ("btn" ++ icon)
            , style (List.append (commonStyle cell) (customStyle dtype cell))
            ]
            [ text letter ]


commonStyle : Model -> List ( String, String )
commonStyle cell =
    [ ( "position", "absolute" )
    , ( "left", (toString (cell.x * cell.width)) ++ "px" )
    , ( "top", (toString (cell.y * cell.width)) ++ "px" )
    , ( "font-size", (toString ((cell.width |> toFloat) * 0.6 |> round)) ++ "px" )
    , ( "margin", "5px" )
    , ( "width", (toString (cell.width - 10)) ++ "px" )
    , ( "height", (toString (cell.width - 10)) ++ "px" )
    , ( "color", "#036" )
    , ( "border-radius", "20px" )
    ]


customStyle : DisplayType -> Model -> List ( String, String )
customStyle dtype cell =
    case dtype of
        HideLetter ->
            [ ( "color", "#d0e0f0" ) ]

        ShowLetter ->
            [ ( "color", "#036" ) ]

        HighlightTail ->
            [ ( "background-color", "rgba(204, 204, 204, 0.3)" )
            , ( "border", "dashed 1px rgba(128, 128, 128, 0.5)" )
            , ( "color", "#036" )
            ]

        HighlightHead ->
            [ ( "background-color", "rgba(153, 204, 255, 0.4)" )
            , ( "border", "solid 1px #036" )
            , ( "color", "#036" )
            ]
