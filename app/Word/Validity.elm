module Word.Validity exposing (..)

-- MODEL


type Validity
    = Invalid
    | Valid
    | Unknown


order : Validity -> Validity -> Order
order a b =
    case ( a, b ) of
        ( Valid, Valid ) ->
            EQ

        ( Invalid, Invalid ) ->
            EQ

        ( Unknown, Unknown ) ->
            EQ

        ( Unknown, _ ) ->
            LT

        ( Invalid, _ ) ->
            GT

        ( _, Unknown ) ->
            GT

        ( _, Invalid ) ->
            LT


toString : Validity -> String
toString validity =
    case validity of
        Valid ->
            "valid"

        Invalid ->
            "invalid"

        Unknown ->
            "unknown"
