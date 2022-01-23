module Main exposing (..)

import Browser
import Html exposing (Html, text, pre)
import Http
import Debug
import Json.Decode as Decode exposing (Decoder, int, string)
import Json.Decode.Pipeline exposing (required, hardcoded, optional)

-- MAIN

main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }


-- MODEL

type Model
  = Failure String
  | Loading
  | Success String

init : () -> (Model, Cmd Msg)
init _ =
  ( Loading
  , Http.get
      { url = "http://localhost:8010/testdata"
      , expect = Http.expectString GotText
      }
  )


-- UPDATE

type Msg
  = GotText (Result Http.Error String)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    GotText result ->
      case result of
        Ok fullText ->
          (Success fullText, Cmd.none)

        Err errCode ->
          (Failure (Debug.toString errCode), Cmd.none)


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


-- VIEW

view : Model -> Html Msg
view model =
  case model of
    Failure errCode->
      text ("I was unable to load your book." ++ errCode)

    Loading ->
      text "Loading..."

    Success fullText ->
      pre [] [ (text "\n\n------------\n"), (text fullText) ]



-- PARSE JSON

type alias SLO =
    { kind: String
    , interval: String
    , target: Int
    }

type alias Dependency =
    { kind: String
    , eventualMax: Int
    , endpoint: String
    , infoEndpoint: String
    , slos: List SLO
    }

type alias ServiceView =
    { version: String
    , name: String
    , endpoint: String
    , infoEndpoint: String
    , dependencies: List Dependency
    , consumers: List String
    }

serviceViewDecoder: Decoder ServiceView
serviceViewDecoder =
    Decode.succeed ServiceView
        |> required "version" string
        |> required "name" string
        |> required "endpoint" string
        |> required "infoEndpoint" string
        |> required "dependencies" (Decode.list dependencyDecoder)
        |> hardcoded []

dependencyDecoder: Decoder Dependency
dependencyDecoder =
    Decode.succeed Dependency
        |> required "kind" string
        |> optional "eventualMax" int 0
        |> required "endpoint" string
        |> required "infoEndpoint" string
        |> required "slos" (Decode.list sloDecoder)


sloDecoder: Decoder SLO
sloDecoder = 
    Decode.succeed SLO
        |> required "kind" string
        |> required "interval" string
        |> required "targetValue" int