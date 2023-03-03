module Main exposing (main)

import Browser
import Html exposing (Html, button, input, pre, table, td, text, tr)
import Html.Attributes exposing (placeholder, type_, value)
import Html.Events exposing (onInput)
import Http


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
    ( Model Nothing "" (SignedOut <| Form "" ""), Cmd.none )


view : Model -> Html Msg
view model =
    case model.status of
        SignedOut form ->
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

        SignedIn token ->
            pre [] [ text token ]


viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
    input [ type_ t, placeholder p, value v, onInput toMsg ] []


type Msg
    = Login
    | UserNameChanged String
    | PasswordChanged String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.status ) of
        ( UserNameChanged username, SignedOut form ) ->
            ( { model | status = SignedOut { form | username = username } }, Cmd.none )

        ( PasswordChanged password, SignedOut form ) ->
            ( { model | status = SignedOut { form | password = password } }, Cmd.none )

        ( _, SignedIn token ) ->
            ( { model | token = token, status = SignedIn token }, Cmd.none )

        ( Login, SignedOut form ) ->
            ( model, Cmd.none )


loginCmd : Form -> Cmd Msg
loginCmd form =
    Cmd.none -- TODO: implmentation using Http.post with multiparBody


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
    = SignedIn String -- bearer token
    | SignedOut Form
