module Tests exposing (..)

import String
import ElmTest exposing (..)
import Main exposing (Card(..) , addNewCardToDeck, positionOfTopCard)

testModel : Main.Model

testModel = { n = 2, score =0, waitingForChoice = False, deck = [ NormalCard { position =1 }, NormalCard { position =2 }, NormalCard { position = 3} ] }

testTopEquals i model = assertEqual (positionOfTopCard (model.deck) (model.n)) i

testTopCardEquals c model = assertEqual (List.head model.deck) c

tests : Test
tests =
    suite "Preserve Deck invariants for addNewCardToDeck"
        [ test "add PositionMatchesBack, position matches older deck item" (addNewCardToDeck testModel PositionMatchesBack |> testTopEquals (Just 2 ))
        , test "add card that matches old card, is transformed into PositionMatchesBack" (addNewCardToDeck testModel (NormalCard { position = 2}) |> testTopCardEquals (Just PositionMatchesBack))
        ]

main : Program Never
main =
    runSuite tests
