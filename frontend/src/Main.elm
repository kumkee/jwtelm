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


{- 
TODO List:
1. Handle http errors, especialy BadStatus 401 Unauthorized
2. Single page application
-}


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
            viewForm form

        SignedIn _ Nothing ->
            pre [] [ text model.token.tokenValue ]

        SignedIn info (Just user) ->
            let
                button_info =
                    case info of
                        "" ->
                            button [ onClick GetItems ] [ text "Get Items" ]

                        _ ->
                            pre [] [ text info ]
            in
            div []
                [ text "User: "
                , text user.username
                , br [] []
                , text "Full name: "
                , text user.fullname
                , br [] []
                , text "Email: "
                , text user.email
                , br [] []
                , button_info
                ]

        Loading target ->
            text <| "Loading " ++ target ++ "..."

        Error err ->
            text <| "Error: " ++ err


viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
    input [ type_ t, placeholder p, value v, onInput toMsg ] []


viewForm : Form -> Html Msg
viewForm form =
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


type Msg
    = Login
    | UserNameChanged String
    | PasswordChanged String
    | GotToken (Result Http.Error Token)
    | GotUser (Result Http.Error User)
    | GotItems (Result Http.Error String)
    | GetItems


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
            ( { model | status = SignedIn "" <| Just user }, Cmd.none )

        ( GotToken (Err error), _ ) ->
            ( { model | status = Error ("GotToken: " ++ Debug.toString error) }
            , Cmd.none
            )

        ( GotUser (Err error), _ ) ->
            ( { model | status = Error ("GotUser: " ++ Debug.toString error) }
            , Cmd.none
            )

        ( GetItems, SignedIn _ _ ) ->
            ( model, getItemsCmd model.token )

        ( GotItems (Ok items), SignedIn _ user ) ->
            ( { model | status = SignedIn items user }, Cmd.none )

        ( _, _ ) ->
            ( model, Cmd.none )


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


requestGetWithToken : String -> Token -> Http.Expect Msg -> Cmd Msg
requestGetWithToken path token msg =
    Http.request
        { method = "GET"
        , headers =
            [ Http.header "Authorization" <|
                Format.value token.tokenValue <|
                    Format.value token.tokenType <|
                        "{{ }} {{ }}"
            ]
        , url = baseUrl ++ path
        , body = Http.emptyBody
        , expect = msg
        , timeout = Nothing
        , tracker = Nothing
        }


getUserCmd : Token -> Cmd Msg
getUserCmd token =
    requestGetWithToken "users/me" token <| Http.expectJson GotUser userDecoder


getItemsCmd : Token -> Cmd Msg
getItemsCmd token =
    requestGetWithToken "users/me/items" token <| Http.expectString GotItems


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
    | SignedIn String (Maybe User)
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
