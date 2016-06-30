import Html exposing (..)
import Html.Attributes exposing (class)
import Html.App as Html
import Array exposing (..)

-- Model

type alias Cell = { contents: String, position: Int }
type alias Model = { cells: Array Cell, note: String  }

type Msg = Reset

update: Msg -> Model -> (Model, Cmd Msg)

update msg model =
    case msg of
        Reset -> (model, Cmd.none)

view: Model -> Html Msg
view model = table [] [ 
    tr []  (List.map (cellView model) [0..2]) ,
    tr []  (List.map (cellView model) [3..5]) , 
    tr []  (List.map (cellView model) [6..8]) ] 


cellView: Model -> Int -> Html Msg
cellView model pos = 
    let cell = Maybe.withDefault ({ contents ="", position = pos }) (Array.get pos model.cells)
    in
       td [ class ("cell" ++ toString cell.position) ] [ text cell.contents ] 

initCells = Array.initialize 9 (Cell "hello")

model : Model 
model = { cells = initCells, note = "starting" }

init = ( model, Cmd.none )

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

main = Html.program { init= init, view = view, update = update, subscriptions = subscriptions }
