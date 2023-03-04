module Main exposing (main)

import Browser
import Debug
import Html exposing (Html, br, button, div, input, pre, table, td, text, tr)
import Html.Attributes exposing (placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode exposing (Decoder, bool, string, succeed)
import Json.Decode.Pipeline exposing (required)
import String.Format as Format


baseUrl : String
baseUrl =
    "https://jwtelm-1-v6024448.deta.app/"


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
    ( initialModel, Cmd.none )


initialModel : Model
initialModel =
    { token = Token "" ""
    , status = SignedOut <| Form "" ""
    }


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
                , tr [] [ td [] [], button [ onClick Login ] [ text "Login" ] ]
                ]

        SignedIn Nothing ->
            pre [] [ text model.token.tokenValue ]

        SignedIn (Just user) ->
            div []
                [ text "User: "
                , text user.username
                , br [] []
                , text "Full name: "
                , text user.fullname
                , br [] []
                , text "Email: "
                , text user.email
                ]

        Loading target ->
            text <| "Loading " ++ target ++ "..."

        Error err ->
            text <| "Error: " ++ err


viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
    input [ type_ t, placeholder p, value v, onInput toMsg ] []


type Msg
    = Login
    | UserNameChanged String
    | PasswordChanged String
    | GotToken (Result Http.Error Token)
    | GotUser (Result Http.Error User)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.status ) of
        ( UserNameChanged username, SignedOut form ) ->
            ( { model | status = SignedOut { form | username = username } }
            , Cmd.none
            )

        ( PasswordChanged password, SignedOut form ) ->
            ( { model | status = SignedOut { form | password = password } }
            , Cmd.none
            )

        ( Login, SignedOut form ) ->
            ( { model | status = Loading "access token" }, loginCmd form )

        ( GotToken (Ok token), _ ) ->
            ( { model | status = Loading "user", token = token }
            , getUserCmd token
            )

        ( GotUser (Ok user), _ ) ->
            ( { model | status = SignedIn <| Just user }, Cmd.none )

        ( GotToken (Err error), _ ) ->
            ( { model | status = Error ("GotToken: " ++ Debug.toString error) }
            , Cmd.none
            )

        ( GotUser (Err error), _ ) ->
            ( { model | status = Error ("GotUser: " ++ Debug.toString error) }
            , Cmd.none
            )

        ( _, _ ) ->
            ( model, Cmd.none )


loginCmd : Form -> Cmd Msg
loginCmd form =
    let
        body =
            Http.stringBody "application/x-www-form-urlencoded" <|
                Format.value form.password <|
                    Format.value form.username <|
                        "username={{ }}&password={{ }}"
    in
    Http.post
        { url = baseUrl ++ "token"
        , body = body
        , expect = Http.expectJson GotToken tokenDecoder
        }


tokenDecoder : Decoder Token
tokenDecoder =
    succeed Token
        |> required "token_type" string
        |> required "access_token" string


userDecoder : Decoder User
userDecoder =
    succeed User
        |> required "username" string
        |> required "email" string
        |> required "full_name" string
        |> required "disabled" bool


getUserCmd : Token -> Cmd Msg
getUserCmd token =
    Http.request
        { method = "GET"
        , headers =
            [ Http.header "Authorization" <|
                Format.value token.tokenValue <|
                    Format.value token.tokenType <|
                        "{{ }} {{ }}"
            ]
        , url = baseUrl ++ "users/me"
        , body = Http.emptyBody
        , expect = Http.expectJson GotUser userDecoder
        , timeout = Nothing
        , tracker = Nothing
        }


type alias Model =
    { token : Token
    , status : Status
    }


type alias Token =
    { tokenType : String
    , tokenValue : String
    }


type Status
    = SignedOut Form
    | SignedIn (Maybe User)
    | Loading String
    | Error String


type alias User =
    { username : String
    , fullname : String
    , email : String
    , disabled : Bool
    }


type alias Form =
    { username : String
    , password : String
    }
