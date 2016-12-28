module Share exposing (..)

import ChildUpdate
import Html exposing (..)
import Html.Attributes exposing (..)


-- MODEL


type alias Share =
    { username : String
    }


reset : Share
reset =
    Share ""



-- UPDATE FOR PARENT


type alias HasOne model =
    { model | share : Share }


updateOne : (Msg -> msg) -> Msg -> HasOne m -> ( HasOne m, Cmd msg )
updateOne =
    ChildUpdate.updateOne update .share (\m x -> { m | share = x })



-- UPDATE


type Msg
    = Challenge


update : Msg -> Share -> ( Share, Cmd Msg )
update msg model =
    case msg of
        Challenge ->
            ( model, Cmd.none )



-- VIEW


view : Bool -> Share -> Html Msg -> Html Msg
view isMobile share timer =
    div [ class "share clearfix" ]
        (if isMobile then
            [ div [ class "box rounded" ] [ mobileShareView share ] ]
         else
            [ div [ class "col col-3" ] [ timer ]
            , div [ class "box rounded px2 col col-9" ] [ shareView share ]
            ]
        )


shareView : Share -> Html Msg
shareView share =
    div [ class "clearfix" ]
        [ div [ class "col col-5" ]
            [ div [] [ text "Enter your name" ]
            , input [ id "username", type_ "text" ] []
            ]
        , div [ class "col col-2" ]
            [ div [ class "chevron fa fa-chevron-right" ] []
            ]
        , div [ class "col col-5" ]
            [ div [] [ text "Challenge a friend" ]
            , div [ class "gray coming-soon" ]
                [ text "Coming soon..."
                ]
            ]
        ]


mobileShareView : Share -> Html Msg
mobileShareView share =
    div []
        [ div [] [ text "Enter your name" ]
        , input [ id "username", type_ "text" ] []
        , div [] [ text "Challenge a friend" ]
        , div [ class "gray coming-soon" ] [ text "Coming soon..." ]
        ]
