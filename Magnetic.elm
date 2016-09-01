module Main exposing (..)

import Dict exposing (..)
import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (on)
import Json.Decode as Json exposing ((:=))
import Mouse exposing (Position)


main : Program Never
main =
    App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    Dict Int Magnet


type alias Magnet =
    { id : Int
    , word : String
    , position : Position
    , drag : Maybe Drag
    }


type alias Drag =
    { start : Position
    , current : Position
    }


init : ( Model, Cmd Msg )
init =
    ( Dict.fromList
        [ ( 1, Magnet 1 "nothing" (Position 200 200) Nothing )
        , ( 2, Magnet 2 "just" (Position 300 300) Nothing )
        ]
    , Cmd.none
    )



-- UPDATE


type Msg
    = DragStart Magnet Position
    | DragAt Magnet Position
    | DragEnd Magnet Position


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        magnet' =
            updateMagnet msg

        {- | Replace the updated magnet on the magnets dictionary. -}
        model' =
            Dict.update magnet'.id (\_ -> Just magnet') model
    in
        ( model', Cmd.none )


updateMagnet : Msg -> Magnet
updateMagnet msg =
    case msg of
        DragStart ({ id, word, position, drag } as magnet) xy ->
            Magnet id word position (Just (Drag xy xy))

        DragAt ({ id, word, position, drag } as magnet) xy ->
            Magnet id word position (Maybe.map (\{ start } -> Drag start xy) drag)

        DragEnd ({ id, word, position, drag } as magnet) _ ->
            Magnet id word (getPosition magnet) Nothing



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        handleMagnet magnet =
            case magnet.drag of
                Nothing ->
                    []

                Just _ ->
                    [ Mouse.moves <| DragAt magnet, Mouse.ups <| DragEnd magnet ]
    in
        Sub.batch <| List.concatMap handleMagnet <| values model



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ pre [] [ text <| toString model ]
        , div [] <| List.map printMagnet <| values model
        ]


printMagnet : Magnet -> Html Msg
printMagnet magnet =
    let
        realPosition =
            getPosition magnet

        px : Int -> String
        px number =
            toString number ++ "px"
    in
        div
            [ on "mousedown" (Json.map (DragStart magnet) Mouse.position)
            , style
                [ ( "background-color", "#3C8D2F" )
                , ( "cursor", "move" )
                , ( "width", "100px" )
                , ( "height", "30px" )
                , ( "border-radius", "2px" )
                , ( "position", "absolute" )
                , ( "left", px realPosition.x )
                , ( "top", px realPosition.y )
                , ( "color", "white" )
                , ( "display", "flex" )
                , ( "align-items", "center" )
                , ( "justify-content", "center" )
                ]
            ]
            [ text magnet.word
            ]


getPosition : Magnet -> Position
getPosition { position, drag } =
    case drag of
        Nothing ->
            position

        Just { start, current } ->
            Position
                (position.x + current.x - start.x)
                (position.y + current.y - start.y)
