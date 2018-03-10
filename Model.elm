module Model exposing (..)


type CardState
    = Open
    | Closed
    | Matched


type GameState
    = Choosing Deck
    | Matching Deck Card
    | GameOver


type Msg
    = CardClicked Card
    | DeckGenerated Deck
    | RestartGame


type Group
    = A
    | B


type alias Deck =
    List Card


type alias Card =
    { id : String
    , state : CardState
    , group : Group
    }


type alias Model =
    { game : GameState }
