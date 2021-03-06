module Board.EngPair exposing (..)


englishPair : Char -> List ( Int, Char )
englishPair other =
    case other of
        'A' ->
            [ ( 1, 'A' )
            , ( 19, 'B' )
            , ( 40, 'C' )
            , ( 62, 'D' )
            , ( 69, 'E' )
            , ( 23, 'F' )
            , ( 26, 'G' )
            , ( 74, 'H' )
            , ( 31, 'I' )
            , ( 2, 'J' )
            , ( 11, 'K' )
            , ( 36, 'L' )
            , ( 44, 'M' )
            , ( 138, 'N' )
            , ( 11, 'O' )
            , ( 27, 'P' )
            , ( 1, 'Q' )
            , ( 78, 'R' )
            , ( 101, 'S' )
            , ( 102, 'T' )
            , ( 10, 'U' )
            , ( 16, 'V' )
            , ( 49, 'W' )
            , ( 1, 'X' )
            , ( 27, 'Y' )
            , ( 1, 'Z' )
            ]

        'B' ->
            [ ( 106, 'A' )
            , ( 7, 'B' )
            , ( 0, 'C' )
            , ( 68, 'D' )
            , ( 239, 'E' )
            , ( 7, 'F' )
            , ( 10, 'G' )
            , ( 7, 'H' )
            , ( 38, 'I' )
            , ( 3, 'J' )
            , ( 3, 'K' )
            , ( 58, 'L' )
            , ( 24, 'M' )
            , ( 24, 'N' )
            , ( 106, 'O' )
            , ( 3, 'P' )
            , ( 0, 'Q' )
            , ( 61, 'R' )
            , ( 44, 'S' )
            , ( 38, 'T' )
            , ( 89, 'U' )
            , ( 0, 'V' )
            , ( 3, 'W' )
            , ( 0, 'X' )
            , ( 61, 'Y' )
            , ( 0, 'Z' )
            ]

        'C' ->
            [ ( 140, 'A' )
            , ( 0, 'B' )
            , ( 17, 'C' )
            , ( 20, 'D' )
            , ( 181, 'E' )
            , ( 7, 'F' )
            , ( 4, 'G' )
            , ( 87, 'H' )
            , ( 92, 'I' )
            , ( 0, 'J' )
            , ( 41, 'K' )
            , ( 20, 'L' )
            , ( 2, 'M' )
            , ( 55, 'N' )
            , ( 127, 'O' )
            , ( 0, 'P' )
            , ( 2, 'Q' )
            , ( 46, 'R' )
            , ( 39, 'S' )
            , ( 57, 'T' )
            , ( 41, 'U' )
            , ( 0, 'V' )
            , ( 2, 'W' )
            , ( 4, 'X' )
            , ( 15, 'Y' )
            , ( 0, 'Z' )
            ]

        'D' ->
            [ ( 108, 'A' )
            , ( 22, 'B' )
            , ( 10, 'C' )
            , ( 28, 'D' )
            , ( 198, 'E' )
            , ( 14, 'F' )
            , ( 10, 'G' )
            , ( 28, 'H' )
            , ( 90, 'I' )
            , ( 3, 'J' )
            , ( 2, 'K' )
            , ( 12, 'L' )
            , ( 16, 'M' )
            , ( 176, 'N' )
            , ( 64, 'O' )
            , ( 7, 'P' )
            , ( 0, 'Q' )
            , ( 37, 'R' )
            , ( 46, 'S' )
            , ( 68, 'T' )
            , ( 18, 'U' )
            , ( 2, 'V' )
            , ( 23, 'W' )
            , ( 0, 'X' )
            , ( 17, 'Y' )
            , ( 0, 'Z' )
            ]

        'E' ->
            [ ( 46, 'A' )
            , ( 29, 'B' )
            , ( 34, 'C' )
            , ( 76, 'D' )
            , ( 40, 'E' )
            , ( 21, 'F' )
            , ( 18, 'G' )
            , ( 139, 'H' )
            , ( 27, 'I' )
            , ( 2, 'J' )
            , ( 14, 'K' )
            , ( 23, 'L' )
            , ( 48, 'M' )
            , ( 73, 'N' )
            , ( 16, 'O' )
            , ( 24, 'P' )
            , ( 1, 'Q' )
            , ( 125, 'R' )
            , ( 78, 'S' )
            , ( 66, 'T' )
            , ( 5, 'U' )
            , ( 37, 'V' )
            , ( 37, 'W' )
            , ( 4, 'X' )
            , ( 17, 'Y' )
            , ( 1, 'Z' )
            ]

        'F' ->
            [ ( 84, 'A' )
            , ( 5, 'B' )
            , ( 7, 'C' )
            , ( 30, 'D' )
            , ( 114, 'E' )
            , ( 50, 'F' )
            , ( 9, 'G' )
            , ( 23, 'H' )
            , ( 91, 'I' )
            , ( 2, 'J' )
            , ( 2, 'K' )
            , ( 18, 'L' )
            , ( 16, 'M' )
            , ( 21, 'N' )
            , ( 273, 'O' )
            , ( 7, 'P' )
            , ( 0, 'Q' )
            , ( 55, 'R' )
            , ( 36, 'S' )
            , ( 105, 'T' )
            , ( 23, 'U' )
            , ( 0, 'V' )
            , ( 9, 'W' )
            , ( 0, 'X' )
            , ( 21, 'Y' )
            , ( 0, 'Z' )
            ]

        'G' ->
            [ ( 102, 'A' )
            , ( 7, 'B' )
            , ( 5, 'C' )
            , ( 22, 'D' )
            , ( 104, 'E' )
            , ( 10, 'F' )
            , ( 19, 'G' )
            , ( 87, 'H' )
            , ( 104, 'I' )
            , ( 2, 'J' )
            , ( 0, 'K' )
            , ( 17, 'L' )
            , ( 10, 'M' )
            , ( 232, 'N' )
            , ( 73, 'O' )
            , ( 2, 'P' )
            , ( 0, 'Q' )
            , ( 53, 'R' )
            , ( 31, 'S' )
            , ( 46, 'T' )
            , ( 51, 'U' )
            , ( 0, 'V' )
            , ( 12, 'W' )
            , ( 0, 'X' )
            , ( 10, 'Y' )
            , ( 0, 'Z' )
            ]

        'H' ->
            [ ( 93, 'A' )
            , ( 2, 'B' )
            , ( 31, 'C' )
            , ( 20, 'D' )
            , ( 261, 'E' )
            , ( 8, 'F' )
            , ( 28, 'G' )
            , ( 9, 'H' )
            , ( 80, 'I' )
            , ( 0, 'J' )
            , ( 2, 'K' )
            , ( 2, 'L' )
            , ( 5, 'M' )
            , ( 13, 'N' )
            , ( 47, 'O' )
            , ( 3, 'P' )
            , ( 0, 'Q' )
            , ( 16, 'R' )
            , ( 43, 'S' )
            , ( 282, 'T' )
            , ( 8, 'U' )
            , ( 0, 'V' )
            , ( 37, 'W' )
            , ( 0, 'X' )
            , ( 11, 'Y' )
            , ( 0, 'Z' )
            ]

        'I' ->
            [ ( 37, 'A' )
            , ( 8, 'B' )
            , ( 32, 'C' )
            , ( 64, 'D' )
            , ( 49, 'E' )
            , ( 31, 'F' )
            , ( 33, 'G' )
            , ( 79, 'H' )
            , ( 2, 'I' )
            , ( 3, 'J' )
            , ( 17, 'K' )
            , ( 28, 'L' )
            , ( 47, 'M' )
            , ( 162, 'N' )
            , ( 28, 'O' )
            , ( 14, 'P' )
            , ( 0, 'Q' )
            , ( 59, 'R' )
            , ( 103, 'S' )
            , ( 129, 'T' )
            , ( 7, 'U' )
            , ( 19, 'V' )
            , ( 35, 'W' )
            , ( 3, 'X' )
            , ( 8, 'Y' )
            , ( 2, 'Z' )
            ]

        'J' ->
            [ ( 81, 'A' )
            , ( 27, 'B' )
            , ( 0, 'C' )
            , ( 81, 'D' )
            , ( 135, 'E' )
            , ( 27, 'F' )
            , ( 27, 'G' )
            , ( 0, 'H' )
            , ( 108, 'I' )
            , ( 0, 'J' )
            , ( 0, 'K' )
            , ( 0, 'L' )
            , ( 0, 'M' )
            , ( 54, 'N' )
            , ( 108, 'O' )
            , ( 0, 'P' )
            , ( 0, 'Q' )
            , ( 27, 'R' )
            , ( 54, 'S' )
            , ( 27, 'T' )
            , ( 216, 'U' )
            , ( 0, 'V' )
            , ( 0, 'W' )
            , ( 0, 'X' )
            , ( 27, 'Y' )
            , ( 0, 'Z' )
            ]

        'K' ->
            [ ( 107, 'A' )
            , ( 6, 'B' )
            , ( 113, 'C' )
            , ( 12, 'D' )
            , ( 202, 'E' )
            , ( 6, 'F' )
            , ( 0, 'G' )
            , ( 12, 'H' )
            , ( 131, 'I' )
            , ( 0, 'J' )
            , ( 0, 'K' )
            , ( 12, 'L' )
            , ( 6, 'M' )
            , ( 101, 'N' )
            , ( 101, 'O' )
            , ( 0, 'P' )
            , ( 0, 'Q' )
            , ( 48, 'R' )
            , ( 65, 'S' )
            , ( 36, 'T' )
            , ( 12, 'U' )
            , ( 0, 'V' )
            , ( 12, 'W' )
            , ( 0, 'X' )
            , ( 18, 'Y' )
            , ( 0, 'Z' )
            ]

        'L' ->
            [ ( 170, 'A' )
            , ( 51, 'B' )
            , ( 27, 'C' )
            , ( 33, 'D' )
            , ( 164, 'E' )
            , ( 24, 'F' )
            , ( 21, 'G' )
            , ( 6, 'H' )
            , ( 110, 'I' )
            , ( 0, 'J' )
            , ( 6, 'K' )
            , ( 0, 'L' )
            , ( 3, 'M' )
            , ( 27, 'N' )
            , ( 77, 'O' )
            , ( 45, 'P' )
            , ( 0, 'Q' )
            , ( 30, 'R' )
            , ( 39, 'S' )
            , ( 51, 'T' )
            , ( 101, 'U' )
            , ( 0, 'V' )
            , ( 6, 'W' )
            , ( 0, 'X' )
            , ( 12, 'Y' )
            , ( 0, 'Z' )
            ]

        'M' ->
            [ ( 140, 'A' )
            , ( 14, 'B' )
            , ( 2, 'C' )
            , ( 30, 'D' )
            , ( 230, 'E' )
            , ( 14, 'F' )
            , ( 8, 'G' )
            , ( 12, 'H' )
            , ( 124, 'I' )
            , ( 0, 'J' )
            , ( 2, 'K' )
            , ( 2, 'L' )
            , ( 20, 'M' )
            , ( 18, 'N' )
            , ( 154, 'O' )
            , ( 24, 'P' )
            , ( 0, 'Q' )
            , ( 34, 'R' )
            , ( 44, 'S' )
            , ( 40, 'T' )
            , ( 32, 'U' )
            , ( 0, 'V' )
            , ( 10, 'W' )
            , ( 0, 'X' )
            , ( 48, 'Y' )
            , ( 0, 'Z' )
            ]

        'N' ->
            [ ( 157, 'A' )
            , ( 5, 'B' )
            , ( 18, 'C' )
            , ( 115, 'D' )
            , ( 126, 'E' )
            , ( 6, 'F' )
            , ( 68, 'G' )
            , ( 12, 'H' )
            , ( 151, 'I' )
            , ( 1, 'J' )
            , ( 12, 'K' )
            , ( 6, 'L' )
            , ( 6, 'M' )
            , ( 11, 'N' )
            , ( 118, 'O' )
            , ( 3, 'P' )
            , ( 1, 'Q' )
            , ( 14, 'R' )
            , ( 31, 'S' )
            , ( 80, 'T' )
            , ( 30, 'U' )
            , ( 1, 'V' )
            , ( 17, 'W' )
            , ( 0, 'X' )
            , ( 10, 'Y' )
            , ( 0, 'Z' )
            ]

        'O' ->
            [ ( 11, 'A' )
            , ( 21, 'B' )
            , ( 39, 'C' )
            , ( 40, 'D' )
            , ( 25, 'E' )
            , ( 80, 'F' )
            , ( 20, 'G' )
            , ( 40, 'H' )
            , ( 24, 'I' )
            , ( 3, 'J' )
            , ( 11, 'K' )
            , ( 17, 'L' )
            , ( 52, 'M' )
            , ( 111, 'N' )
            , ( 48, 'O' )
            , ( 24, 'P' )
            , ( 0, 'Q' )
            , ( 93, 'R' )
            , ( 57, 'S' )
            , ( 115, 'T' )
            , ( 78, 'U' )
            , ( 11, 'V' )
            , ( 50, 'W' )
            , ( 0, 'X' )
            , ( 27, 'Y' )
            , ( 1, 'Z' )
            ]

        'P' ->
            [ ( 136, 'A' )
            , ( 3, 'B' )
            , ( 0, 'C' )
            , ( 19, 'D' )
            , ( 184, 'E' )
            , ( 9, 'F' )
            , ( 3, 'G' )
            , ( 13, 'H' )
            , ( 57, 'I' )
            , ( 0, 'J' )
            , ( 0, 'K' )
            , ( 47, 'L' )
            , ( 38, 'M' )
            , ( 13, 'N' )
            , ( 114, 'O' )
            , ( 63, 'P' )
            , ( 0, 'Q' )
            , ( 76, 'R' )
            , ( 79, 'S' )
            , ( 47, 'T' )
            , ( 70, 'U' )
            , ( 0, 'V' )
            , ( 3, 'W' )
            , ( 9, 'X' )
            , ( 16, 'Y' )
            , ( 0, 'Z' )
            ]

        'Q' ->
            [ ( 63, 'A' )
            , ( 0, 'B' )
            , ( 63, 'C' )
            , ( 0, 'D' )
            , ( 125, 'E' )
            , ( 0, 'F' )
            , ( 0, 'G' )
            , ( 0, 'H' )
            , ( 0, 'I' )
            , ( 0, 'J' )
            , ( 0, 'K' )
            , ( 0, 'L' )
            , ( 0, 'M' )
            , ( 63, 'N' )
            , ( 0, 'O' )
            , ( 0, 'P' )
            , ( 0, 'Q' )
            , ( 0, 'R' )
            , ( 125, 'S' )
            , ( 0, 'T' )
            , ( 563, 'U' )
            , ( 0, 'V' )
            , ( 0, 'W' )
            , ( 0, 'X' )
            , ( 0, 'Y' )
            , ( 0, 'Z' )
            ]

        'R' ->
            [ ( 114, 'A' )
            , ( 16, 'B' )
            , ( 19, 'C' )
            , ( 31, 'D' )
            , ( 275, 'E' )
            , ( 22, 'F' )
            , ( 20, 'G' )
            , ( 18, 'H' )
            , ( 70, 'I' )
            , ( 1, 'J' )
            , ( 7, 'K' )
            , ( 9, 'L' )
            , ( 15, 'M' )
            , ( 17, 'N' )
            , ( 127, 'O' )
            , ( 22, 'P' )
            , ( 0, 'Q' )
            , ( 26, 'R' )
            , ( 37, 'S' )
            , ( 64, 'T' )
            , ( 51, 'U' )
            , ( 4, 'V' )
            , ( 13, 'W' )
            , ( 0, 'X' )
            , ( 22, 'Y' )
            , ( 0, 'Z' )
            ]

        'S' ->
            [ ( 132, 'A' )
            , ( 11, 'B' )
            , ( 15, 'C' )
            , ( 34, 'D' )
            , ( 154, 'E' )
            , ( 13, 'F' )
            , ( 11, 'G' )
            , ( 45, 'H' )
            , ( 110, 'I' )
            , ( 2, 'J' )
            , ( 9, 'K' )
            , ( 11, 'L' )
            , ( 18, 'M' )
            , ( 35, 'N' )
            , ( 69, 'O' )
            , ( 20, 'P' )
            , ( 2, 'Q' )
            , ( 33, 'R' )
            , ( 70, 'S' )
            , ( 117, 'T' )
            , ( 45, 'U' )
            , ( 2, 'V' )
            , ( 23, 'W' )
            , ( 0, 'X' )
            , ( 19, 'Y' )
            , ( 0, 'Z' )
            ]

        'T' ->
            [ ( 89, 'A' )
            , ( 6, 'B' )
            , ( 14, 'C' )
            , ( 35, 'D' )
            , ( 87, 'E' )
            , ( 25, 'F' )
            , ( 10, 'G' )
            , ( 198, 'H' )
            , ( 93, 'I' )
            , ( 1, 'J' )
            , ( 3, 'K' )
            , ( 9, 'L' )
            , ( 11, 'M' )
            , ( 62, 'N' )
            , ( 94, 'O' )
            , ( 8, 'P' )
            , ( 0, 'Q' )
            , ( 38, 'R' )
            , ( 78, 'S' )
            , ( 61, 'T' )
            , ( 36, 'U' )
            , ( 1, 'V' )
            , ( 19, 'W' )
            , ( 2, 'X' )
            , ( 20, 'Y' )
            , ( 0, 'Z' )
            ]

        'U' ->
            [ ( 28, 'A' )
            , ( 46, 'B' )
            , ( 33, 'C' )
            , ( 30, 'D' )
            , ( 23, 'E' )
            , ( 18, 'F' )
            , ( 37, 'G' )
            , ( 18, 'H' )
            , ( 16, 'I' )
            , ( 14, 'J' )
            , ( 4, 'K' )
            , ( 60, 'L' )
            , ( 28, 'M' )
            , ( 74, 'N' )
            , ( 203, 'O' )
            , ( 39, 'P' )
            , ( 16, 'Q' )
            , ( 98, 'R' )
            , ( 96, 'S' )
            , ( 114, 'T' )
            , ( 0, 'U' )
            , ( 0, 'V' )
            , ( 5, 'W' )
            , ( 0, 'X' )
            , ( 4, 'Y' )
            , ( 0, 'Z' )
            ]

        'V' ->
            [ ( 149, 'A' )
            , ( 0, 'B' )
            , ( 0, 'C' )
            , ( 12, 'D' )
            , ( 530, 'E' )
            , ( 0, 'F' )
            , ( 0, 'G' )
            , ( 0, 'H' )
            , ( 149, 'I' )
            , ( 0, 'J' )
            , ( 0, 'K' )
            , ( 0, 'L' )
            , ( 0, 'M' )
            , ( 12, 'N' )
            , ( 95, 'O' )
            , ( 0, 'P' )
            , ( 0, 'Q' )
            , ( 24, 'R' )
            , ( 12, 'S' )
            , ( 6, 'T' )
            , ( 0, 'U' )
            , ( 0, 'V' )
            , ( 0, 'W' )
            , ( 0, 'X' )
            , ( 12, 'Y' )
            , ( 0, 'Z' )
            ]

        'W' ->
            [ ( 158, 'A' )
            , ( 2, 'B' )
            , ( 2, 'C' )
            , ( 42, 'D' )
            , ( 178, 'E' )
            , ( 8, 'F' )
            , ( 10, 'G' )
            , ( 96, 'H' )
            , ( 92, 'I' )
            , ( 0, 'J' )
            , ( 4, 'K' )
            , ( 4, 'L' )
            , ( 10, 'M' )
            , ( 48, 'N' )
            , ( 150, 'O' )
            , ( 2, 'P' )
            , ( 0, 'Q' )
            , ( 28, 'R' )
            , ( 56, 'S' )
            , ( 70, 'T' )
            , ( 6, 'U' )
            , ( 0, 'V' )
            , ( 8, 'W' )
            , ( 0, 'X' )
            , ( 26, 'Y' )
            , ( 0, 'Z' )
            ]

        'X' ->
            [ ( 83, 'A' )
            , ( 0, 'B' )
            , ( 83, 'C' )
            , ( 0, 'D' )
            , ( 417, 'E' )
            , ( 0, 'F' )
            , ( 0, 'G' )
            , ( 0, 'H' )
            , ( 167, 'I' )
            , ( 0, 'J' )
            , ( 0, 'K' )
            , ( 0, 'L' )
            , ( 0, 'M' )
            , ( 0, 'N' )
            , ( 0, 'O' )
            , ( 125, 'P' )
            , ( 0, 'Q' )
            , ( 0, 'R' )
            , ( 0, 'S' )
            , ( 125, 'T' )
            , ( 0, 'U' )
            , ( 0, 'V' )
            , ( 0, 'W' )
            , ( 0, 'X' )
            , ( 0, 'Y' )
            , ( 0, 'Z' )
            ]

        'Y' ->
            [ ( 123, 'A' )
            , ( 50, 'B' )
            , ( 19, 'C' )
            , ( 45, 'D' )
            , ( 111, 'E' )
            , ( 25, 'F' )
            , ( 11, 'G' )
            , ( 39, 'H' )
            , ( 31, 'I' )
            , ( 3, 'J' )
            , ( 8, 'K' )
            , ( 11, 'L' )
            , ( 67, 'M' )
            , ( 39, 'N' )
            , ( 114, 'O' )
            , ( 14, 'P' )
            , ( 0, 'Q' )
            , ( 67, 'R' )
            , ( 64, 'S' )
            , ( 100, 'T' )
            , ( 6, 'U' )
            , ( 6, 'V' )
            , ( 36, 'W' )
            , ( 0, 'X' )
            , ( 11, 'Y' )
            , ( 0, 'Z' )
            ]

        'Z' ->
            [ ( 222, 'A' )
            , ( 0, 'B' )
            , ( 0, 'C' )
            , ( 0, 'D' )
            , ( 333, 'E' )
            , ( 0, 'F' )
            , ( 0, 'G' )
            , ( 0, 'H' )
            , ( 333, 'I' )
            , ( 0, 'J' )
            , ( 0, 'K' )
            , ( 0, 'L' )
            , ( 0, 'M' )
            , ( 0, 'N' )
            , ( 111, 'O' )
            , ( 0, 'P' )
            , ( 0, 'Q' )
            , ( 0, 'R' )
            , ( 0, 'S' )
            , ( 0, 'T' )
            , ( 0, 'U' )
            , ( 0, 'V' )
            , ( 0, 'W' )
            , ( 0, 'X' )
            , ( 0, 'Y' )
            , ( 0, 'Z' )
            ]

        _ ->
            [ ( 81, 'A' )
            , ( 14, 'B' )
            , ( 27, 'C' )
            , ( 43, 'D' )
            , ( 120, 'E' )
            , ( 23, 'F' )
            , ( 20, 'G' )
            , ( 59, 'H' )
            , ( 73, 'I' )
            , ( 1, 'J' )
            , ( 6, 'K' )
            , ( 39, 'L' )
            , ( 26, 'M' )
            , ( 69, 'N' )
            , ( 76, 'O' )
            , ( 18, 'P' )
            , ( 1, 'Q' )
            , ( 60, 'R' )
            , ( 62, 'S' )
            , ( 91, 'T' )
            , ( 28, 'U' )
            , ( 11, 'V' )
            , ( 20, 'W' )
            , ( 1, 'X' )
            , ( 21, 'Y' )
            , ( 1, 'Z' )
            ]
