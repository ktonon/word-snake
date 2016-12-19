module Board.Cell exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, style)
import ChildUpdate


-- MODEL


type alias Model =
    { id : Id
    , letter : String
    , x : Int
    , y : Int
    , adj : List Id
    }


type alias Id =
    String


type alias Bounds =
    ( Int, Int )


type alias Pos =
    ( Int, Int )


makeId : Pos -> Id
makeId ( x, y ) =
    (toString x) ++ "_" ++ (toString y)


init : Bounds -> Int -> Int -> Char -> Model
init bounds x y letter =
    let
        pos =
            ( x, y )
    in
        findNeighbours bounds pos
            |> Model (makeId pos) (String.fromChar letter) x y


findNeighbours : Bounds -> Pos -> List Id
findNeighbours bounds ( x, y ) =
    [ ( x - 1, y - 1 )
    , ( x - 1, y )
    , ( x - 1, y + 1 )
    , ( x, y - 1 )
    , ( x, y + 1 )
    , ( x + 1, y - 1 )
    , ( x + 1, y )
    , ( x + 1, y + 1 )
    ]
        |> List.filterMap (inBoundId bounds)


inBoundId : Bounds -> Pos -> Maybe Id
inBoundId ( min, max ) ( x, y ) =
    if x < min || x > max || y < min || y > max then
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
    = ShowLetter
    | HighlightHead
    | HighlightTail


view : DisplayType -> Model -> Html Msg
view dtype cell =
    button
        [ class ("btn")
        , style (List.append (commonStyle cell) (customStyle dtype cell))
        ]
        [ text cell.letter ]


commonStyle : Model -> List ( String, String )
commonStyle cell =
    [ ( "position", "absolute" )
    , ( "left", (toString (cell.x * 150)) ++ "px" )
    , ( "top", (toString (cell.y * 150)) ++ "px" )
    , ( "font-size", "64pt" )
    , ( "margin", "5px" )
    , ( "width", "140px" )
    , ( "height", "140px" )
    , ( "color", "#036" )
    , ( "border-radius", "20px" )
    ]


customStyle : DisplayType -> Model -> List ( String, String )
customStyle dtype cell =
    case dtype of
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