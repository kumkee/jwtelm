module Main exposing (main)

import Browser
import Html exposing (Html, button, div, input, table, td, text, tr)
import Html.Attributes exposing (placeholder, type_, value)
import Html.Events exposing (onInput)


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
        Logout form ->
            table []
                [ tr []
                    [ td [] [ text "Username: " ]
                    , td []
                        [ viewInput "text"
                            "username"
                            form.username
                            UserNameChanged
                        ]
                    ]
                , tr []
                    [ td [] [ text "Password: " ]
                    , td []
                        [ viewInput "password"
                            "password"
                            form.password
                            PasswordChanged
                        ]
                    ]
                , tr [] [ td [] [], button [] [ text "Login" ] ]
                ]

        Login token ->
            div [] [ text token ]


viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
    input [ type_ t, placeholder p, value v, onInput toMsg ] []


type Msg
    = GotToken String
    | UserNameChanged String
    | PasswordChanged String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.status ) of
        ( GotToken token, _ ) ->
            ( { model | token = token, status = Login token }, Cmd.none )

        ( UserNameChanged username, Logout form ) ->
            ( { model | status = Logout { form | username = username } }, Cmd.none )

        ( PasswordChanged password, Logout form ) ->
            ( { model | status = Logout { form | password = password } }, Cmd.none )

        ( _, Login _ ) ->
            ( model, Cmd.none )


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
