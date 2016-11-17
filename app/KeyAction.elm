module KeyAction exposing (..)

import Char
import Keyboard exposing (KeyCode)
import String


type KeyAction
    = Letter String
    | Cancel
    | Commit
    | Undo


actionFromCode : KeyCode -> KeyAction
actionFromCode code =
    if code == 27 then
        Cancel
    else if code == 8 then
        Undo
    else if code == 32 || code == 13 then
        Commit
    else
        Letter (code |> Char.fromCode |> String.fromChar)
