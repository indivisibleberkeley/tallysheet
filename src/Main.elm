module Main exposing (main)

import Browser
import Html exposing (button, text)
import Html.Events exposing (onClick)
import Http
import Json.Decode exposing (Decoder, field, int)
import Debug
import Time


main : Program Json.Decode.Value Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    Int


init : Json.Decode.Value -> ( Model, Cmd Msg )
init _ =
    ( 0, Cmd.none )


type Msg
    = Increment
    | SendReset
    | Reset (Result Http.Error ())
    | RetrieveCount
    | UpdateCount (Result Http.Error Int)
    | Pass (Result Http.Error ())


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Increment ->
            ( model + 1
            , Http.post
                { url = "http://127.0.0.1:5000/api/increment"
                , body = Http.emptyBody
                , expect = Http.expectWhatever Pass
                }
            )

        SendReset ->
            ( model
            , Http.post
                { url = "http://127.0.0.1:5000/api/reset"
                , body = Http.emptyBody
                , expect = Http.expectWhatever Reset
                }
            )

        Reset result ->
            case Debug.log "Reset result" result of
                Ok _ ->
                    ( 0, Cmd.none )

                Err _ ->
                    ( -1, Cmd.none )

        RetrieveCount ->
            ( model
            , Http.get
                { url = "http://127.0.0.1:5000/api/get"
                , expect = Http.expectJson UpdateCount tallyDecoder
                }
            )

        UpdateCount result ->
            case result of
                Ok newValue ->
                    ( newValue, Cmd.none )

                Err _ ->
                    ( -1, Cmd.none )

        Pass _ ->
            ( model, Cmd.none )

tallyDecoder : Decoder Int
tallyDecoder =
    field "tally1" int


view : Model -> Browser.Document Msg
view model =
    { title = "Tally sheet"
    , body =
        [ text (String.fromInt model)
        , button [ onClick Increment ] [ text "+1 Call" ]
        , button [ onClick SendReset ] [ text "reset" ]
        ]
    }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Time.every 1000 (\_ -> RetrieveCount)
