module Shuffle exposing (..)

import Html exposing (..)
import Html.Attributes exposing (alt, class, href, id, src, style)
import Html.Events exposing (onClick)
import Routing.Shape as Shape exposing (Shape(..))


-- MODEL


type SizeChange
    = Smaller
    | Same
    | Bigger


changeShape : Shape -> SizeChange -> Shape
changeShape shape sizeChange =
    let
        s =
            Shape.smallest

        l =
            Shape.largest
    in
        case ( shape, sizeChange ) of
            ( Shape x y, Bigger ) ->
                Shape (min (x + 1) l) (min (y + 1) l)

            ( Shape x y, Smaller ) ->
                Shape (max (x - 1) s) (max (y - 1) s)

            ( shape, _ ) ->
                shape



-- VIEW


buttons : (SizeChange -> msg) -> Shape -> Html msg
buttons mapMsg shape =
    let
        ( showSmaller, showBigger ) =
            case shape of
                Shape x y ->
                    if x == Shape.smallest && y == Shape.smallest then
                        ( False, True )
                    else if x == Shape.largest && y == Shape.largest then
                        ( True, False )
                    else
                        ( True, True )
    in
        div [ class "center py2" ]
            [ button mapMsg "shuffle-smaller" "" "fa fa-th-large" Smaller showSmaller
            , button mapMsg "shuffle" "Shuffle" "" Same True
            , button mapMsg "shuffle-bigger" "" "fa fa-th" Bigger showBigger
            ]


button : (SizeChange -> msg) -> String -> String -> String -> SizeChange -> Bool -> Html msg
button mapMsg id_ label icon sizeChange show =
    if show then
        a
            [ class ("shuffle m1 " ++ icon)
            , id id_
            , onClick (mapMsg sizeChange)
            ]
            [ text label ]
    else
        span [ class ("shuffle disabled m1 " ++ icon) ] [ text label ]
