module Main exposing (main)

--import Html exposing (button, div, text)
--import Html.Events exposing (onClick)

import Browser
import Debug
import Dict exposing (Dict)
import Element exposing (layout, text)
import Element.Border as Border
import Element.Input as Input
import Http
import Json.Decode exposing (Decoder, field, int, list, map, map2, string)
import Time
import Url.Builder



-- MAIN


main : Program Json.Decode.Value Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


increment : TallyScope -> String -> Model -> Model
increment scope name model =
    case model of
        Loading ->
            Loading

        Data group local ->
            case scope of
                Group ->
                    Data
                        (Dict.update name
                            (Maybe.map ((+) 1))
                            group
                        )
                        local

                Local ->
                    Data group <|
                        Dict.update name
                            (Maybe.map ((+) 1))
                            local


type alias Tallies =
    Dict String Int


emptyLike : Tallies -> Tallies
emptyLike tallies =
    List.foldl (\k d -> Dict.insert k 0 d) Dict.empty (Dict.keys tallies)


type Model
    = Loading
    | Data Tallies Tallies -- Data group local


type TallyScope
    = Group
    | Local


init : Json.Decode.Value -> ( Model, Cmd Msg )
init _ =
    ( Loading
    , Http.get
        { url =
            Url.Builder.relative
                [ "api"
                , "all"
                ]
                []
        , expect = Http.expectJson UpdateAll allDecoder
        }
    )



-- MSG


type Msg
    = Increment String
    | SendReset String
    | RetrieveCount String
    | UpdateCount String (Result Http.Error Int)
    | UpdateAll (Result Http.Error Tallies)



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Increment name ->
            ( increment Local name model
            , Http.post
                { url =
                    Url.Builder.relative
                        [ "api"
                        , "increment"
                        , name
                        ]
                        []
                , body = Http.emptyBody
                , expect = Http.expectJson (UpdateCount name) countDecoder
                }
            )

        SendReset name ->
            ( model
            , Http.post
                { url =
                    Url.Builder.relative
                        [ "api"
                        , "reset"
                        , name
                        ]
                        []
                , body = Http.emptyBody
                , expect = Http.expectJson (UpdateCount name) countDecoder
                }
            )

        RetrieveCount name ->
            ( model
            , Http.get
                { url =
                    Url.Builder.relative
                        [ "api"
                        , "get"
                        , name
                        ]
                        []
                , expect = Http.expectJson (UpdateCount name) countDecoder
                }
            )

        UpdateCount name countResult ->
            case model of
                Loading ->
                    ( Loading, Cmd.none )

                Data group local ->
                    case countResult of
                        Ok count ->
                            ( Data
                                (Dict.insert name count group)
                                local
                            , Cmd.none
                            )

                        Err err ->
                            ( Debug.log (Debug.toString err) model, Cmd.none )

        UpdateAll result ->
            case result of
                Ok tallies ->
                    ( Data tallies (emptyLike tallies), Cmd.none )

                Err err ->
                    ( Debug.log (Debug.toString err) model
                    , Cmd.none
                    )



-- DECODERS


countDecoder : Decoder Int
countDecoder =
    field "count" int


type alias JsonTally =
    { name : String
    , count : Int
    }


tallyDecoder : Decoder JsonTally
tallyDecoder =
    map2 JsonTally
        (field "name" string)
        (field "count" int)


tallyListDecoder : Decoder (List ( String, Int ))
tallyListDecoder =
    list tallyTupleDecoder


tallyTupleDecoder : Decoder ( String, Int )
tallyTupleDecoder =
    map (\tally -> ( tally.name, tally.count )) tallyDecoder


allDecoder : Decoder Tallies
allDecoder =
    map Dict.fromList tallyListDecoder



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Tally sheet"
    , body =
        [ layout [] <|
            case model of
                Loading ->
                    text "Loading..."

                Data group local ->
                    Element.column []
                        [ viewGroupTallies group
                        , viewLocalTallies local
                        ]
        ]
    }


padding : Int
padding =
    20


spacing : Int
spacing =
    20


buttonStyle : List (Element.Attribute msg)
buttonStyle =
    [ Border.color <| Element.rgb 0.6 0.6 0.6
    , Border.rounded 5
    , Border.solid
    , Border.width 2
    , Element.padding 10
    ]


columnStyle : List (Element.Attribute msg)
columnStyle =
    [ Element.padding padding, Element.spacing spacing ]


tallyColumn : List (Element.Element msg) -> Element.Element msg
tallyColumn =
    Element.column columnStyle


mainButton :
    { onPress : Maybe msg, label : Element.Element msg }
    -> Element.Element msg
mainButton =
    Input.button buttonStyle


viewLocalTallies : Tallies -> Element.Element Msg
viewLocalTallies tallies =
    Element.row []
        [ tallyColumn [ text "Your tally" ]
        , tallyColumn <|
            List.map
                (\( _, count ) ->
                    text (String.fromInt count)
                )
                (Dict.toList tallies)
        , tallyColumn <|
            List.map
                (\( name, _ ) ->
                    mainButton
                        { onPress = Just <| Increment name
                        , label =
                            text ("+1 " ++ name)
                        }
                )
                (Dict.toList tallies)
        ]


viewGroupTallies : Tallies -> Element.Element Msg
viewGroupTallies tallies =
    Element.row []
        [ tallyColumn [ text "Group tally" ]
        , tallyColumn <|
            List.map
                (\( _, count ) ->
                    text (String.fromInt count)
                )
                (Dict.toList tallies)
        , tallyColumn <|
            List.map
                (\( name, _ ) ->
                    mainButton
                        { onPress = Just <| SendReset name
                        , label =
                            text ("reset " ++ name)
                        }
                )
                (Dict.toList tallies)
        ]



-- SUBSCRIPTIONS


retrieveCountSub : String -> Sub Msg
retrieveCountSub name =
    Time.every 1000 (\_ -> RetrieveCount name)


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        Loading ->
            Sub.none

        Data group _ ->
            Sub.batch (List.map retrieveCountSub (Dict.keys group))
