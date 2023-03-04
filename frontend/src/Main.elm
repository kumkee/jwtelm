module Main exposing (main)

import Browser
import Debug
import Html exposing (Html, br, button, div, input, label, pre, text)
import Html.Attributes exposing (action, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import Http
import String.Format as Format


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
            Html.form []
                [ label []
                    [ text "Username: "
                    , viewInput "text" "username" form.username UserNameChanged
                    ]
                , br [] []
                , label []
                    [ text "Password: "
                    , viewInput "text" "password" form.password PasswordChanged
                    ]
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


viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
    input [ type_ t, placeholder p, value v, onInput toMsg ] []


type Msg
    = Login
    | UserNameChanged String
    | PasswordChanged String
    | GotToken (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( UserNameChanged username, SignedOut form ) ->
            ( SignedOut { form | username = username }, Cmd.none )

        ( PasswordChanged password, SignedOut form ) ->
            ( SignedOut { form | password = password }, Cmd.none )

        ( Login, SignedOut form ) ->
            ( model, loginCmd form )

        ( GotToken (Ok token), _ ) ->
            ( SignedIn token Nothing, Cmd.none )

        ( GotToken (Err error), _ ) ->
            ( SignedIn (Debug.toString error) Nothing, Cmd.none )

        ( _, SignedIn _ _ ) ->
            ( model, Cmd.none )


loginCmd : Form -> Cmd Msg
loginCmd form =
    -- Cmd.none -- TODO: implmentation using Http.post with multiparBody
    let
        body =
            Http.stringBody "application/x-www-form-urlencoded" <|
                Format.value form.password <|
                    Format.value form.username <|
                        "username={{ }}&password={{ }}"
    in
    Http.post
        { url = "https://jwtelm-1-v6024448.deta.app/token"
        , body = body
        , expect = Http.expectString GotToken
        }


type Model
    = SignedOut Form
    | SignedIn String (Maybe User)


type alias User =
    { username : String
    , fullname : String
    , email : String
    }


type alias Form =
    { username : String
    , password : String
    }
