module Main exposing (..)

import Model exposing (..)
import Html exposing (..)
import DeckGenerator exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Random


-- ==========================================================
-- VIEW
-- ==========================================================


boardStyle : Attribute msg
boardStyle =
    style
        [ ( "width", "800px" )
        ]


cardStyle : Attribute msg
cardStyle =
    style
        [ ( "width", "200px" )
        , ( "height", "200px" )
        ]


viewCard : Card -> Html Msg
viewCard card =
    case card.state of
        Open ->
            img
                [ class "open"
                , src ("/public/cats/" ++ card.id ++ ".jpg")
                , cardStyle
                ]
                []

        Closed ->
            img
                [ class "closed"
                , onClick (CardClicked card)
                , src ("/public/cats/closed.png")
                , cardStyle
                ]
                []

        Matched ->
            img
                [ class "matched"
                , src ("/public/cats/" ++ card.id ++ ".jpg")
                , cardStyle
                ]
                []


viewCards : Deck -> Html Msg
viewCards cards =
    div [ boardStyle ] (List.map viewCard cards)


view : Model -> Html Msg
view model =
    case model.game of
        Choosing deck ->
            viewCards deck

        Matching deck card ->
            viewCards deck

        GameOver ->
            div [ class "victory" ]
                [ text "You won!"
                , button
                    [ class "restart"
                    , onClick RestartGame
                    ]
                    [ text "Click to restart"
                    ]
                ]



-- ==========================================================
-- CONTROLLER
-- ==========================================================


setCard : CardState -> Card -> Deck -> Deck
setCard state card deck =
    List.map
        (\c ->
            if c.id == card.id && c.group == card.group then
                { card | state = state }
            else
                c
        )
        deck


closeUnmatched : Deck -> Deck
closeUnmatched deck =
    List.map
        (\c ->
            if c.state /= Matched then
                { c | state = Closed }
            else
                c
        )
        deck


isMatching : Card -> Card -> Bool
isMatching c1 c2 =
    c1.id == c2.id && c1.group /= c2.group


allMatched : Deck -> Bool
allMatched deck =
    List.all (\c -> c.state == Matched) deck


updateCardClick : Card -> GameState -> GameState
updateCardClick clickedCard gameState =
    case gameState of
        Choosing deck ->
            let
                updatedDeck =
                    deck
                        |> closeUnmatched
                        |> setCard Open clickedCard
            in
                Matching updatedDeck clickedCard

        Matching deck openCard ->
            let
                updatedDeck =
                    if isMatching clickedCard openCard then
                        deck
                            |> setCard Matched clickedCard
                            |> setCard Matched openCard
                    else
                        setCard Open clickedCard deck
            in
                if allMatched updatedDeck then
                    GameOver
                else
                    Choosing updatedDeck

        GameOver ->
            gameState


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CardClicked card ->
            ( { model | game = updateCardClick card model.game }, Cmd.none )

        DeckGenerated deck ->
            ( { game = Choosing deck }, Cmd.none )

        RestartGame ->
            ( init, Cmd.none )



-- ==========================================================
-- INITIALIZE/RUNNER
-- ==========================================================


init : Model
init =
    { game = Choosing DeckGenerator.static }


main : Program Never Model Msg
main =
    Html.program
        { init =
            ( init
            , Random.generate DeckGenerated DeckGenerator.random
            )
        , view = view
        , update = update
        , subscriptions = \s -> Sub.none
        }
