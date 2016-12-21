module Util exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Config.Config as Config


forkMe : Config.Model -> Html msg
forkMe config =
    case config.forkMe of
        Just forkMe ->
            a [ class "fork-me", href ("https://github.com/" ++ forkMe) ]
                [ img
                    [ src "https://camo.githubusercontent.com/38ef81f8aca64bb9a64448d0d70f1308ef5341ab/68747470733a2f2f73332e616d617a6f6e6177732e636f6d2f6769746875622f726962626f6e732f666f726b6d655f72696768745f6461726b626c75655f3132313632312e706e67"
                    , alt "Fork me on GitHub"
                    ]
                    []
                ]

        Nothing ->
            span [] []
