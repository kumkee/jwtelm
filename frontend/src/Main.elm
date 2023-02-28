module Main exposing (main)

import Browser
import Html exposing (Html, button, div, input, text)
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


view : Model -> Html Msg
view model =
    case model of
        Logout ->
            div []
                [ [ text "Username: " ]
                , [ input [ placeholder "username" ] ]
                ]

        Login token ->
            div [] [ text token ]


type Msg
    = GotToken String


update: Model -> Msg -> Model
update _ msg =
    case msg of
        GotToken token ->
            Login token


type Model
    = Status


type Status
    = Login String -- bearer token
    | Logout
