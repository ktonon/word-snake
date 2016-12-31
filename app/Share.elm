module Share exposing (..)

import Challenge.Challenge as Challenge exposing (..)
import ChildUpdate
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Routing.Token as Token exposing (..)
import Task


-- MODEL


type alias Share =
    { player : String
    , challengeId : String
    }


reset : Share
reset =
    Share "" ""



-- UPDATE FOR PARENT


type alias HasOne model =
    { model | share : Share }


updateOne : ( String, Int, Token ) -> (Msg -> msg) -> Msg -> HasOne m -> ( HasOne m, Cmd msg )
updateOne extra =
    ChildUpdate.updateOne (update extra) .share (\m x -> { m | share = x })



-- UPDATE


type Msg
    = Challenge
    | ChallengeResult (Result Challenge.Error Challenge)
    | UpdatePlayer String


update : ( String, Int, Token ) -> Msg -> Share -> ( Share, Cmd Msg )
update ( apiEndpoint, score, token ) msg model =
    case msg of
        Challenge ->
            ( model
            , Challenge.create
                apiEndpoint
                ( model.player, score, token )
                |> Task.attempt ChallengeResult
            )

        ChallengeResult r ->
            case r of
                Ok challenge ->
                    ( { model | challengeId = challenge.id }, Cmd.none )

                Err err ->
                    ( model, Cmd.none )

        UpdatePlayer name ->
            ( { model | player = name }, Cmd.none )



-- VIEW


view : Bool -> Share -> Html Msg -> Html Msg
view isMobile share timer =
    let
        parts =
            ( [ div [] [ text "Enter your name" ]
              , input
                    [ id "username"
                    , onInput UpdatePlayer
                    , type_ "text"
                    ]
                    []
              ]
            , [ challengeButton share
              , if String.isEmpty share.challengeId then
                    span [] []
                else
                    input [ value share.challengeId ] []
              ]
            )
    in
        div [ class "share clearfix" ]
            (if isMobile then
                [ div [ class "box rounded" ] [ mobileShareView share parts ] ]
             else
                [ div [ class "col col-5" ] [ timer ]
                , div [ class "box rounded px2 col col-7" ] [ shareView share parts ]
                ]
            )


challengeButton : Share -> Html Msg
challengeButton share =
    let
        attr =
            if share.player |> String.isEmpty then
                [ class "button disabled" ]
            else
                [ class "button", onClick Challenge ]
    in
        a attr [ text "Challenge a friend" ]


shareView : Share -> ( List (Html Msg), List (Html Msg) ) -> Html Msg
shareView share ( player, challenge ) =
    div [ class "clearfix" ]
        [ div [ class "col col-5" ] player
        , div [ class "col col-2" ]
            [ div [ class "chevron fa fa-chevron-right" ] []
            ]
        , div [ class "col col-5" ] challenge
        ]


mobileShareView : Share -> ( List (Html Msg), List (Html Msg) ) -> Html Msg
mobileShareView share ( player, challenge ) =
    div [] (List.concat [ player, challenge ])
