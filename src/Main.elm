module Main exposing (main)

import Browser
import Html exposing (button, text)
import Html.Events exposing (onClick)
import Json.Decode


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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Increment ->
            ( model + 1, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    { title = "Tally sheet"
    , body =
        [ text (String.fromInt model)
        , button [ onClick Increment ] [ text "+1 Call" ]
        ]
    }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
