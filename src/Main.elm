module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, style)
import Html.App as Html
import Html.Events exposing (onClick)
import Random
import Time exposing (second)
import Instructions


-- Model


type alias Cell =
    Int


type Card
    = NormalCard { position : Cell }
    | PositionMatchesBack


type GameStage
    = WaitingForChoice
    | Intro
    | WaitingForNextCard
    | Paused


type alias Deck =
    List Card



-- n = number of cards back to match, deck
-- deck = collection of past Cards (positions)
-- score = current score


type alias Model =
    { n : Int, deck : Deck, score : Int, stage : GameStage }



-- Messages


type Msg
    = NewCard
    | StartGame
    | QuitGame
    | PauseGame
    | GotRandomCard Card
    | VisualNBackMatch
    | TimerEnded Time.Time



-- Picks a random card (each card has its own position). This picker chooses a
-- non-matching card 8/11 and an N-Back match 3/11.


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
    { m | stage = WaitingForChoice }


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
        StartGame ->
            update NewCard { model | score = 0, stage = WaitingForNextCard }

        QuitGame ->
            ( { model | stage = Intro }, Cmd.none )

        PauseGame ->
            ( { model | stage = Paused }, Cmd.none )

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
            update NewCard { model | stage = WaitingForNextCard }


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


introView : Model -> Html Msg
introView model =
    div []
        [ Instructions.instructionsHtml
        , button [ onClick StartGame ] [ text "Start the Game" ]
        ]


view : Model -> Html Msg
view model =
    div [ class "row" ]
        [ div [ (class "center-block"), (style [ ( "width", "640px" ), ( "background-color", "#f0f0f0" ) ]) ]
            [ case model.stage of
                Intro ->
                    introView model

                _ ->
                    deckView model
            ]
        ]


deckView : Model -> Html Msg
deckView model =
    div []
        [ table []
            [ tr [] [ showCardOrNot model (0), showCardOrNot model (1), showCardOrNot model (2) ]
            , tr [] [ showCardOrNot model (3), showCardOrNot model (4), showCardOrNot model (5) ]
            , tr [] [ showCardOrNot model (6), showCardOrNot model (7), showCardOrNot model (8) ]
            ]
        , div [] [ text ("Score:" ++ toString (model.score)) ]
        , if isPositionTheSame model then
            text "NBACK!"
          else
            text "NOBACK!"
        , div [] [ button [ onClick VisualNBackMatch ] [ text "Visual Match" ] ]
        , div [] [ button [ onClick QuitGame ] [ text "Quit Game" ] ]
        , div []
            [ if model.stage == Paused then
                button [ onClick NewCard ] [ text "Unpause" ]
              else
                button [ onClick PauseGame ] [ text "Pause Game" ]
            ]
        ]


init : ( Model, Cmd a )
init =
    ( { n = 2, score = 0, stage = Intro, deck = [ PositionMatchesBack, NormalCard { position = 3 }, NormalCard { position = 2 } ] }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    if model.stage == WaitingForChoice then
        Time.every (2 * second) TimerEnded
    else
        Sub.none


main : Program Never
main =
    Html.program { init = init, view = view, update = update, subscriptions = subscriptions }
