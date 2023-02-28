module Main exposing (main)

import Browser
import Html exposing (Html, button, div, text, input)
import Html.Attributes exposing (placeholder)
import Html.Events exposing (onClick)


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = Sub.none
        , view = view
        }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Logout, Cmd.none )


view: Model -> Html Msg
view model =
    case model of
        Logout ->
            div []
                [ [ text "Username: "]
                , [ input [placeholder "username"] ]
                ]


type Msg
    = GotToken String


type Model
    = Status


type Status
    = Login String -- bearer token
    | Logout
