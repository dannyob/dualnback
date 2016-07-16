module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, style)
import Html.App as Html
import Html.Events exposing (onClick)
import Random
import Debug
import Time exposing (second)


-- Model


type alias Cell =
    Int


type Card
    = NormalCard { position : Cell }
    | PositionMatchesBack


type alias Deck =
    List Card


type alias Model =
    { n : Int, deck : Deck, score : Int, waitingForChoice : Bool }



-- n = number of cards back to match, deck
-- deck = collection of past Cards (positions)
-- score = current score
-- Messages


type Msg
    = NewCard
    | GotRandomCard Card
    | VisualNBackMatch
    | TimerEnded Time.Time



-- Picks a random card (each card has its own position). This picker chooses a
-- non-matching card 8/11 and an N-Back match 3/11.
-- Note (model.n-1) in this is to compensate for the fact that it will be used just before a new card is added: so
-- the distance between the final new card and the nback match is one less than you'd expect.


randomCard : Random.Generator Card
randomCard =
    let
        whichCard a =
            if a < 0 then
                PositionMatchesBack
            else
                NormalCard { position = a }
    in
        Random.map whichCard (Random.int (-2) 8)


startTimer : Model -> Model
startTimer m =
    { m | waitingForChoice = True }


addNewCardToDeck : Model -> Card -> Model
addNewCardToDeck model newcard =
    let
        matchesNBack =
            case newcard of
                PositionMatchesBack ->
                    True

                position ->
                    if (Just position == (List.head (List.drop (model.n - 1) model.deck))) then
                        True
                    else
                        False
    in
        if (matchesNBack) then
            { model | deck = PositionMatchesBack :: model.deck }
        else
            { model | deck = newcard :: model.deck }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewCard ->
            ( model, Random.generate GotRandomCard randomCard )

        GotRandomCard card ->
            ( startTimer (addNewCardToDeck model card), Cmd.none )

        VisualNBackMatch ->
            if (isPositionTheSame model) then
                ( { model | score = model.score + 1 }, Cmd.none )
            else
                ( { model | score = model.score - 1 }, Cmd.none )

        TimerEnded a ->
            update NewCard { model | waitingForChoice = False }


isPositionTheSame : Model -> Bool
isPositionTheSame model =
    List.head model.deck == Just PositionMatchesBack


positionOfTopCard : List Card -> Int -> Maybe Int
positionOfTopCard deck nback =
    let
        topcard =
            List.head deck
    in
        let
            nbackdeck =
                (List.drop nback deck)
        in
            case topcard of
                Just (NormalCard i) ->
                    Just i.position

                Just PositionMatchesBack ->
                    positionOfTopCard nbackdeck nback

                Nothing ->
                    Nothing


showCardOrNot : Model -> Int -> Html Msg
showCardOrNot model cell =
    let
        xo =
            case positionOfTopCard model.deck model.n of
                Nothing ->
                    ( "background-color", "grey" )

                Just i ->
                    if i == cell then
                        ( "background-color", "red" )
                    else
                        ( "background-color", "grey" )
    in
        td [ style [ ( "border", "2px solid black" ), ( "width", "100px" ), ( "height", "100px" ), xo ] ] []


view : Model -> Html Msg
view model =
    deckView model


deckView : Model -> Html Msg
deckView model =
    div []
        [ table []
            [ tr [] [ showCardOrNot model (0), showCardOrNot model (1), showCardOrNot model (2) ]
            , tr [] [ showCardOrNot model (3), showCardOrNot model (4), showCardOrNot model (5) ]
            , tr [] [ showCardOrNot model (6), showCardOrNot model (7), showCardOrNot model (8) ]
            ]
        , div [] [ text ("Score:" ++ toString (model.score)) ]
        , button [ onClick NewCard ] [ text "New Cards, Please" ]
        , if isPositionTheSame model then
            text "NBACK!"
          else
            text "NOBACK!"
        , div [] [ button [ onClick VisualNBackMatch ] [ text "Visual Match" ] ]
        ]


init : ( Model, Cmd a )
init =
    ( { n = 2, score = 0, deck = [ PositionMatchesBack, NormalCard { position = 3 }, NormalCard { position = 2 } ], waitingForChoice = False }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    if model.waitingForChoice then
        Time.every (2 * second) TimerEnded
    else
        Sub.none


main : Program Never
main =
    Html.program { init = init, view = view, update = update, subscriptions = subscriptions }
