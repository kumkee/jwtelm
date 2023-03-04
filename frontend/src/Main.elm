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
    ( SignedOut <| Form "" "", Cmd.none )


view : Model -> Html Msg
view model =
    case model of
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

        SignedIn token Nothing ->
            pre [] [ text token ]

        SignedIn _ (Just user) ->
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
            text <| "Loading" ++ target ++ "..."


viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
    input [ type_ t, placeholder p, value v, onInput toMsg ] []


type Msg
    = Login
    | UserNameChanged String
    | PasswordChanged String
    | GotToken (Result Http.Error String)
    | GotUser (Result Http.Error User)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( UserNameChanged username, SignedOut form ) ->
            ( SignedOut { form | username = username }, Cmd.none )

        ( PasswordChanged password, SignedOut form ) ->
            ( SignedOut { form | password = password }, Cmd.none )

        ( Login, SignedOut form ) ->
            ( Loading "access token", loginCmd form )

        ( GotToken (Ok token), _ ) ->
            ( SignedIn token Nothing, getUserCmd token )

        ( GotUser (Ok user), SignedIn token Nothing ) ->
            ( SignedIn token <| Just user, Cmd.none)

        ( GotToken (Err error), _ ) ->
            ( SignedIn ("GotToken: " ++ Debug.toString error) Nothing, Cmd.none )

        ( GotUser (Err error), _ ) ->
            ( SignedIn ("GotUser: " ++ Debug.toString error) Nothing, Cmd.none )

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
        , expect = Http.expectString GotToken
        }


userDecoder : Decoder User
userDecoder =
    succeed User
        |> required "username" string
        |> required "email" string
        |> required "full_name" string
        |> required "disabled" bool


getUserCmd : String -> Cmd Msg
getUserCmd token =
    Http.request
        { method = "GET"
        , headers =
            [ Http.header "accept: application/json" <|
                "Authorization: Bearer "
                    ++ token
            ]
        , url = baseUrl ++ "users/me"
        , body = Http.emptyBody
        , expect = Http.expectJson GotUser userDecoder
        , timeout = Nothing
        , tracker = Nothing
        }


type Model
    = SignedOut Form
    | SignedIn String (Maybe User)
    | Loading String


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
