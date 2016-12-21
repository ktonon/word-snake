module Shuffle exposing (..)

import Html exposing (..)
import Html.Attributes exposing (alt, class, href, id, src, style)
import Html.Events exposing (onClick)
import Routing.Shape exposing (Shape(..))


-- MODEL


type SizeChange
    = Smaller
    | Same
    | Bigger


changeShape : Shape -> SizeChange -> Shape
changeShape shape sizeChange =
    case ( shape, sizeChange ) of
        ( Board3x3, Bigger ) ->
            Board4x4

        ( Board4x4, Smaller ) ->
            Board3x3

        ( Board4x4, Bigger ) ->
            Board5x5

        ( Board5x5, Smaller ) ->
            Board4x4

        ( board, _ ) ->
            board



-- VIEW


buttons : (SizeChange -> msg) -> Shape -> Html msg
buttons mapMsg shape =
    let
        ( showSmaller, showBigger ) =
            case shape of
                Board3x3 ->
                    ( False, True )

                Board5x5 ->
                    ( True, False )

                _ ->
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
