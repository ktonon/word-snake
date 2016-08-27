module Board.Cell exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, style)


-- MODEL


type alias Model =
    { id : Id
    , letter : String
    , x : Int
    , y : Int
    , adj : List String
    }


type alias Id =
    String


type alias ExtraClass =
    String


type alias CheckAdjacent =
    Model -> Maybe Model -> Bool



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


view : ExtraClass -> Model -> Html Msg
view extraClass cell =
    button
        [ class ("btn rounded " ++ extraClass)
        , style
            [ ( "position", "absolute" )
            , ( "left", (toString (cell.x * 150)) ++ "px" )
            , ( "top", (toString (cell.y * 150)) ++ "px" )
            , ( "font-size", "64pt" )
            , ( "margin", "5px" )
            , ( "width", "140px" )
            , ( "height", "140px" )
            ]
        ]
        [ text cell.letter ]


debugView : Model -> Html Msg
debugView cell =
    div [] [ text cell.letter ]
