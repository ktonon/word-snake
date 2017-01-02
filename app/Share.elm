module Share exposing (..)

import Config.Config as Config
import Challenge.Challenge as Challenge exposing (..)
import ChildUpdate
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onBlur, onClick, onInput)
import Routing.Token as Token exposing (..)
import Task


-- MODEL


type alias Share =
    { player : String
    , pending : Bool
    , challenge : Maybe Challenge
    }


reset : Share
reset =
    Share "" False Nothing



-- UPDATE FOR PARENT


type alias HasOne model =
    { model | share : Share }


updateOne : ( String, Int, Token ) -> (Msg -> msg) -> Msg -> HasOne m -> ( HasOne m, Cmd msg )
updateOne params =
    ChildUpdate.updateOne (update params) .share (\m x -> { m | share = x })



-- UPDATE


type Msg
    = Challenge
    | ChallengeResult (Result Challenge.Error Challenge)
    | UpdatePlayer String


update : ( String, Int, Token ) -> Msg -> Share -> ( Share, Cmd Msg )
update params msg model =
    case msg of
        Challenge ->
            case model.challenge of
                Just challenge ->
                    if Challenge.hasPlayer challenge model.player then
                        ( model, Cmd.none )
                    else
                        createChallenge model params

                Nothing ->
                    if model.player |> String.isEmpty then
                        ( model, Cmd.none )
                    else
                        createChallenge model params

        ChallengeResult r ->
            case r of
                Ok challenge ->
                    ( { model
                        | challenge = Just challenge
                        , pending = False
                      }
                    , Cmd.none
                    )

                Err err ->
                    ( { model | pending = False }, Cmd.none )

        UpdatePlayer name ->
            ( { model | player = name }, Cmd.none )


createChallenge : Share -> ( String, Int, Token ) -> ( Share, Cmd Msg )
createChallenge model ( apiEndpoint, score, token ) =
    if model.pending then
        ( model, Cmd.none )
    else
        ( { model | pending = True }
        , Challenge.create
            apiEndpoint
            ( model.player, score, token )
            |> Task.attempt ChallengeResult
        )



-- VIEW


view : Config.Model -> Share -> Html Msg -> Html Msg
view config share timer =
    let
        parts =
            ( [ div [] [ text "Enter your name" ]
              , input
                    [ id "username"
                    , onInput UpdatePlayer
                    , onBlur Challenge
                    , type_ "text"
                    ]
                    []
              ]
            , [ div [] [ challengeButton share ]
              , let
                    url =
                        case share.challenge of
                            Just challenge ->
                                (config.endpoints.app ++ "/#play/" ++ challenge.id)

                            Nothing ->
                                ""
                in
                    a [ href url, class "share-link" ] [ text url ]
              ]
            )
    in
        div [ class "share clearfix" ]
            (if config.isMobile then
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

        label =
            case share.challenge of
                Just _ ->
                    [ text "Challenge a friend (share this link)" ]

                Nothing ->
                    [ text "Challenge a friend" ]
    in
        a attr label


shareView : Share -> ( List (Html Msg), List (Html Msg) ) -> Html Msg
shareView share ( player, challenge ) =
    div [ class "clearfix" ]
        [ div [ class "col col-4" ] player
        , div [ class "col col-1 center" ]
            [ div [ class "chevron fa fa-chevron-right" ] []
            ]
        , div [ class "col col-7" ] challenge
        ]


mobileShareView : Share -> ( List (Html Msg), List (Html Msg) ) -> Html Msg
mobileShareView share ( player, challenge ) =
    div [] (List.concat [ player, challenge ])
