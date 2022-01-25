module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Html exposing (Html)
import Http
import Debug
import Url
import Json.Decode as Decode exposing (Decoder, int, string)
import Json.Decode.Pipeline exposing (required, hardcoded, optional)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Dialog exposing (..)

-- MAIN
main : Program () Model Msg
main =
  Browser.application
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    , onUrlChange = UrlChanged
    , onUrlRequest = LinkClicked
    }


-- MODEL

type Model
  = Failure String
  | Loading
  | Success ServiceView String 

init : () -> Url.Url -> Nav.Key -> (Model, Cmd Msg)
init _ _ _ =
  ( Loading
  , Http.get
      { url = "http://localhost:8010/testdata"
      , expect = Http.expectString GotText
      }
  )


-- UPDATE

type Msg
  = GotText (Result Http.Error String)
  | UrlChanged Url.Url
  | LinkClicked Browser.UrlRequest



update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    GotText result ->
      case result of
        Ok fullText ->
          case (Decode.decodeString serviceViewDecoder fullText) of
            (Ok service) ->  
               (Success  service fullText, Cmd.none)
            
            (Err errCode) -> 
               (Failure ((Debug.toString errCode) ++ ": \n¸\n" ++ fullText), Cmd.none)

        Err errCode ->
          (Failure (Debug.toString errCode), Cmd.none)

    UrlChanged _ ->
      ( model, Cmd.none )

    LinkClicked _ ->
      ( model, Cmd.none )


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


-- VIEW

view : Model -> Browser.Document Msg
view model =
  case model of
    Failure errCode->
        { title = "SLOView: Service View"
        , body = [ Html.text ("I was unable to load the service view: " ++ errCode) ]
        }

    Loading ->
        { title = "SLOView: Loading"
        , body = [ Html.text ("Loading...") ]
        }

    Success service fullText ->    
        viewSuccess service fullText


viewSuccess service fullText =
  { title = "SLOView: Service View"
  , body = [  Element.layout []
           <| column [width fill] 
                [ row [] [(text service.name)]
                , row [] [(text "-------------")]
                , row [] [ (text fullText)]
                ]
        ]
  }

            

-- PARSE JSON
-- TODO: convert me to use https://package.elm-lang.org/packages/fujiy/elm-json-convert/latest/

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