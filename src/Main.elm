import Html exposing (Html, table, tr, td, text, div)
import Html.Attributes exposing (class)
import Html.App as Html

-- Model

type alias Model = { note: String  }

type Msg = Reset

update: Msg -> Model -> Model
update msg model =
    case msg of
        Reset -> { note = "hello" }


view :Model -> Html Msg
view model = table [] [ 
    tr [ class "row1" ] [ td [ class "col1" ] [ text "x" ] , td [ class "col2"] [ text "y" ] , td [ class "col3" ] [ text "z" ] ],
    tr [ class "row2" ] [ td [ class "col1" ] [ text "x" ] , td [ class "col2"] [ text "y" ] , td [ class "col3" ] [ text "z" ] ],
    tr [ class "row3" ] [ td [ class "col1" ] [ text "x" ] , td [ class "col2"] [ text "y" ] , td [ class "col3" ] [ text "z" ] ]
    ]


model : Model 
model = { note = "starting" }

main = Html.beginnerProgram { model = model, view = view, update = update }
