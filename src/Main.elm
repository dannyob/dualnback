import Html exposing (..)
import Html.Attributes exposing (class)
import Html.App as Html
import Array exposing (..)

-- Model

type alias Card = { audio: String, visual: Int }
type alias Cell = { contents: String, position: Int }
type alias Model = { cards: List Card, note: String  }

type Msg = Reset

initialCard: Card
initialCard = { audio = "Yowza", visual = 5 }


update: Msg -> Model -> (Model, Cmd Msg)

update msg model =
    case msg of
        Reset -> (model, Cmd.none)

view: Model -> Html Msg
view model = cardView model (Maybe.withDefault initialCard (List.head model.cards) )

cardView: Model -> Card -> Html Msg
cardView model card = 
    let cv model ps = if (ps == card.visual) then text "HELLO" else text "NOOO"
    in
       table [] [ 
           tr []  (List.map (cv model) [0..2]) ,
           tr []  (List.map (cv model) [3..5]) , 
           tr []  (List.map (cv model) [6..8]) ] 


model : Model 
model = { cards = [ initialCard ] , note = "starting" }

init = ( model, Cmd.none )

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

main = Html.program { init= init, view = view, update = update, subscriptions = subscriptions }
