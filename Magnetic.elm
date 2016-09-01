module Main exposing (..)

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
    List Magnet


type alias Magnet =
    { word : String
    , position : Position
    , drag : Maybe Drag
    }


type alias Drag =
    { start : Position
    , current : Position
    }


init : ( Model, Cmd Msg )
init =
    ( [ Magnet "nothing" (Position 200 200) Nothing
      , Magnet "just" (Position 300 300) Nothing
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
    ( [ (updateHelp msg) ], Cmd.none )


updateHelp : Msg -> Magnet
updateHelp msg =
    case msg of
        DragStart ({ word, position, drag } as magnet) xy ->
            Magnet word position (Just (Drag xy xy))

        DragAt ({ word, position, drag } as magnet) xy ->
            Magnet word position (Maybe.map (\{ start } -> Drag start xy) drag)

        DragEnd ({ word, position, drag } as magnet) _ ->
            Magnet word (getPosition magnet) Nothing



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
        Sub.batch <| List.concatMap handleMagnet model



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ pre [] [ text <| toString model ]
        , div [] <| List.map printMagnet model
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
