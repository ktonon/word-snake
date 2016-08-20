module Cell exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, style)


-- MODEL


type alias Model =
    { letter : String
    , x : Int
    , y : Int
    }



-- UPDATE


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg cell =
    case msg of
        NoOp ->
            ( cell, Cmd.none )



-- VIEW


view : Model -> Html Msg
view cell =
    button
        [ class "btn white bg-blue rounded"
        , style
            [ ( "position", "absolute" )
            , ( "left", (toString (cell.x * 150)) ++ "px")
            , ( "top", (toString (cell.y * 150)) ++ "px")
            , ( "font-size", "64pt" )
            , ( "margin", "5px" )
            , ( "width", "140px" )
            , ( "height", "140px" )
            ]
        ]
        [ text cell.letter ]
