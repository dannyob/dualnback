import Html exposing (..)
import Html.Attributes exposing (class, style)
import Html.App as Html
import Html.Events exposing (onClick)
import Time exposing (every,second)
import Random

-- Model

type alias Model = { deck: Deck , score: Int }

type Msg = Reset | NewCard | RandomCard Int | VisualNBackMatch

type alias Cell = Int
type alias Card = { position: Cell }

type alias Deck = List Card


update: Msg -> Model -> (Model, Cmd Msg)
update msg model = case msg of
                                  Reset -> (model, Cmd.none)
                                  NewCard -> (model, Random.generate RandomCard (Random.int (0-2) 8))
                                  RandomCard random_int -> if (random_int >= 0) then (addNewCardToDeck model { position = random_int  }, Cmd.none) else (addNewCardToDeck model (nbackCard model 2), Cmd.none)
                                  VisualNBackMatch -> if (isPositionTheSame model 2) then ({ model |  score = model.score + 1 }, Cmd.none) else ({ model | score = model.score - 1 }, Cmd.none)

view: Model -> Html Msg
view model = deckView model

nbackCard model nback = Maybe.withDefault  { position = 1 }  (List.head (List.drop nback model.deck))

isPositionTheSame model nback = 
    let
        h = List.head model.deck -- Maybe value
        f = List.head (List.drop nback model.deck)  -- Maybe value
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

deckView model = 
    let tc = List.head model.deck
    in div [] [table [] [ 
             tr [] [ showCardOrNot tc (0), showCardOrNot tc (1) , showCardOrNot tc (2) ]
           , tr [] [ showCardOrNot tc (3), showCardOrNot tc (4) , showCardOrNot tc (5) ]
           , tr [] [ showCardOrNot tc (6), showCardOrNot tc (7) , showCardOrNot tc (8) ]
           ], div [] [text ("Score:" ++ toString (model.score))],  button [onClick NewCard] [ text "New Cards, Please" ], if isPositionTheSame model 2 then text "NBACK!" else text "NOBACK!" , div [] [ button [onClick VisualNBackMatch] [ text "Visual Match" ] ]]
                                                                          


init : ( Model, Cmd a )
init = ( { score = 0 , deck= [ { position = 5} , { position = 3 }, { position = 2} ] } , Cmd.none )

addNewCardToDeck : Model -> Card -> Model
addNewCardToDeck model newcard  = { model | deck = newcard :: model.deck }

subscriptions : Model -> Sub Msg
subscriptions model = Sub.none

main : Program Never
main = Html.program { init= init, view = view, update = update, subscriptions = subscriptions }
