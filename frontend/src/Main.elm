module Main exposing (main)

import Browser
import Html exposing (Html, div, input, text)
import Html.Attributes exposing (placeholder, value)


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        , view = view
        }


init : () -> ( Model, Cmd Msg )
init () =
    ( Model Nothing "" Logout, Cmd.none )


view : Model -> Html Msg
view model =
    let
        username =
            case model.user of
                Nothing ->
                    "null"

                Just user ->
                    user.username
    in
    case model.status of
        Logout ->
            div []
                [ text "Username: "
                , input [ placeholder "username", value username ] []
                ]

        Login token ->
            div [] [ text token ]


type Msg
    = GotToken String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotToken token ->
            ( { model | token = token }, Cmd.none )


type alias Model =
    { user : Maybe User
    , token : String
    , status : Status
    }


type alias User =
    { username : String
    , fullname : String
    , email : String
    }


type Status
    = Login String -- bearer token
    | Logout
