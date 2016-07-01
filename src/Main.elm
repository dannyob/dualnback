import Html exposing (..)
import Html.Attributes exposing (class, style)
import Html.App as Html
import Array exposing (..)
import Html.Events exposing (onClick)

-- Model

type alias Card = { audio: String, visual: Int }
type alias Cell = { contents: String, position: Int }
type alias Model = { cards: List Card, speaking: Maybe String}

type Msg = Reset 
         | Say String
         | FinishSpeaking

initialCard: Card
initialCard = { audio = "Yowza", visual = 5 }


update: Msg -> Model -> (Model, Cmd Msg)

update msg model =
    case msg of
        Reset -> (model, Cmd.none)
        Say s -> ({model | speaking = Just s }, Cmd.none)
        FinishSpeaking -> ({model | speaking = Nothing }, Cmd.none)

view: Model -> Html Msg
view model = cardView model (Maybe.withDefault initialCard (List.head model.cards) )

cardView: Model -> Card -> Html Msg
cardView model card = 
    let cv model ps = if (ps == card.visual) then td [style [ ("backgroundColor", "red")  ]] [ text "" ]   else td [] [text ""]
    in
       div [] [table [ style [ ("width", "100%"), ("height", "200px" ) ] ] [ 
           tr []  (List.map (cv model) [0..2]) ,
           tr []  (List.map (cv model) [3..5]) , 
           tr []  (List.map (cv model) [6..8]) ] ,
           text (case model.speaking of 
              Just x -> x
              Nothing -> "shhh"),
             button [ onClick (Say "hello") ] [ text "hello" ] ]


model : Model 
model = { cards = [ initialCard ] , speaking = Nothing }

init = ( model, Cmd.none )

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

main = Html.program { init= init, view = view, update = update, subscriptions = subscriptions }
