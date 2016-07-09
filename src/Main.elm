import Html exposing (..)
import Html.Attributes exposing (class, style)
import Html.App as Html
import Html.Events exposing (onClick)
import Random
import Debug

import Time exposing (second)

-- Model

type alias Cell = Int
type alias Card = { position: Cell }
type alias Deck = List Card

type alias Model = { n: Int, deck: Deck , score: Int, waitingForChoice: Bool } -- n = number of cards back to match, deck
                                                       -- deck = collection of past Cards (positions)
                                                       -- score = current score

-- Messages

type Msg = NewCard | GotRandomCard (Model -> Card) | VisualNBackMatch | TimerEnded Time.Time

-- Picks a random card (each card has its own position). This picker chooses a
-- non-matching card 8/11 and an N-Back match 3/11.

-- Note (model.n-1) in this is to compensate for the fact that it will be used just before a new card is added: so
-- the distance between the final new card and the nback match is one less than you'd expect.

randomCard : Random.Generator (Model -> Card)
randomCard =
    let nbackCard model = Maybe.withDefault  { position = 1 }  (List.head (List.drop (model.n - 1)  model.deck)) in
    let m a model = if a < 0 then nbackCard model else { position =  a  }
             in Random.map m (Random.int (0-2) 8)

startTimer : Model -> Model
startTimer m =  { m | waitingForChoice = True }
    
update: Msg -> Model -> (Model, Cmd Msg)
update msg model = case msg of 
                                  NewCard -> Debug.log "NewCard Received" (model, Random.generate GotRandomCard (randomCard))
                                  GotRandomCard cardMaker -> (startTimer (addNewCardToDeck model (cardMaker model)),  Cmd.none)
                                  VisualNBackMatch -> if (isPositionTheSame model) then ({ model |  score = model.score + 1 }, Cmd.none) else ({ model | score = model.score - 1 }, Cmd.none)
                                  TimerEnded a -> update NewCard { model | waitingForChoice = False }

isPositionTheSame : Model -> Bool
isPositionTheSame model =
    let
        h = List.head model.deck
        f = List.head (List.drop model.n model.deck)
    in
        h == f


showCardOrNot : Maybe Card -> Cell -> Html Msg
showCardOrNot card cell  =
    let
        xo = case card of
            Nothing -> ("background-color", "grey")
            Just b -> if b.position == cell then ("background-color", "red") else ("background-color", "grey")
    in
       td [style [("border", "2px solid black"), ("width","100px"),("height", "100px"), xo]] []

view: Model -> Html Msg
view model = deckView model

deckView : Model -> Html Msg
deckView model =
    let tc = List.head model.deck
    in div [] [table [] [
             tr [] [ showCardOrNot tc (0), showCardOrNot tc (1) , showCardOrNot tc (2) ]
           , tr [] [ showCardOrNot tc (3), showCardOrNot tc (4) , showCardOrNot tc (5) ]
           , tr [] [ showCardOrNot tc (6), showCardOrNot tc (7) , showCardOrNot tc (8) ] ]
           , div [] [text ("Score:" ++ toString (model.score))] 
           , button [onClick NewCard] [ text "New Cards, Please" ] 
           , if isPositionTheSame model then text "NBACK!" else text "NOBACK!" 
           , div [] [ button [onClick VisualNBackMatch] [ text "Visual Match" ] ] ]

init : ( Model, Cmd a )
init = ( { n = 2, score = 0 , deck= [ { position = 5} , { position = 3 }, { position = 2} ], waitingForChoice = False } , Cmd.none )

addNewCardToDeck : Model -> Card -> Model
addNewCardToDeck model newcard  = { model | deck = newcard :: model.deck }

subscriptions : Model -> Sub Msg
subscriptions model = if model.waitingForChoice then Time.every (2*second) (always NewCard) else Sub.none

main : Program Never
main = Html.program { init= init, view = view, update = update, subscriptions = subscriptions }
