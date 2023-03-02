module Main exposing (main)

import Browser
import Html exposing (Html, button, div, input, table, td, text, tr)
import Html.Attributes exposing (placeholder, type_, value)


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        , view = view
        }


init : () -> ( Model, Cmd Msg )
init () =
    ( Model Nothing "" (Logout <| Form "" ""), Cmd.none )


view : Model -> Html Msg
view model =
    case model.status of
        Logout form->
            table []
                [ tr []
                    [ td [] [ text "Username: " ]
                    , td []
                        [ input [ placeholder "username", value form.username ]
                            []
                        ]
                    ]
                , tr []
                    [ td [] [ text "Password: " ]
                    , td []
                        [ input [ type_ "password", placeholder "password" ]
                            []
                        ]
                    ]
                , tr [] [ td [] [], button [] [ text "Login" ] ]
                ]

        Login token ->
            div [] [ text token ]


type Msg
    = GotToken String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotToken token ->
            ( { model | token = token, status = Login token }, Cmd.none )


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


type alias Form = 
    { username : String
    , password : String
    }


type Status
    = Login String -- bearer token
    | Logout Form
