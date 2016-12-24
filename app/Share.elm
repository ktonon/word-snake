module Share exposing (..)

import ChildUpdate
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)


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


view : Share -> Html Msg -> Html Msg
view share timer =
    div [ class "share clearfix" ]
        [ div [ class "col col-3" ] [ timer ]
        , div [ class "box rounded px2 col col-9" ]
            [ div [ class "clearfix" ]
                [ div [ class "col col-5" ]
                    [ div [] [ text "Enter your name" ]
                    , input [ id "username", type_ "text" ] []
                    ]
                , div [ class "col col-2" ]
                    [ div [ class "fa fa-chevron-right" ] []
                    ]
                , div [ class "col col-5" ]
                    [ div [] [ text "Challenge a friend" ]
                    , div [ class "gray" ] [ text "Coming soon..." ]
                    ]
                ]
            ]
        ]
