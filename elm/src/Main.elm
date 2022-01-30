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
import Widget
import Widget.Icon as Icon
import Widget.Material as Material


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
  | Success ServiceView Int String 

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
  | ChangedTab Int



update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    GotText result ->
      case result of
        Ok fullText ->
          case (Decode.decodeString serviceViewDecoder fullText) of
            (Ok service) ->  
               -- set to first tab initially
               (Success  service 1 fullText, Cmd.none)
            
            (Err errCode) -> 
               (Failure ((Debug.toString errCode) ++ ": \n¸\n" ++ fullText), Cmd.none)

        Err errCode ->
          (Failure (Debug.toString errCode), Cmd.none)

    UrlChanged _ ->
      ( model, Cmd.none )

    LinkClicked _ ->
      ( model, Cmd.none )

    ChangedTab tab ->
        case model of
            Success service _ fullText ->
                (Success service tab fullText, Cmd.none)
            _ -> 
                (Failure "full text not received yet", Cmd.none)


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

    Success service selectedTab fullText ->    
        viewSuccess service selectedTab fullText


viewSuccess: ServiceView -> Int -> String -> Browser.Document Msg
viewSuccess service selectedTab fullText =
  { title = "SLOView: Service View"
  , body = [  Element.layout []
           <| column [width fill, spacing 25] 
                [ (viewHeader service)
                , (serviceCard service)
                , (viewTabs selectedTab service)
                , (viewFooter service)
--                , row [] [(text "-------------")]
--                , row [] [ (text fullText)]
                ]
        ]
  }

serviceCard service =
     el (List.append cardStyle [ width (px 300), height (px 120)]) 
        (column [ width fill, height fill, spacing 15, padding 5]
               [ row [width fill] [el[alignLeft](text "Service name: "), el[alignRight](text service.name)]
               , row [width fill] [el[alignLeft](text "Endpoint: "), el[alignRight](text service.endpoint)]
               ])
     

viewTabs: Int -> ServiceView -> Element Msg
viewTabs selected service =
    Widget.tab (Material.tab Material.defaultPalette)
        { tabs =
            { selected = Just selected
            , options =
                [ { text = "dependencies"
                  , icon = always Element.none
                  }
                , { text = "consumers"
                   , icon = always Element.none
                  }
                ]
            , onSelect = ChangedTab >> Just
            }
        , content =
            \s ->
                (case s of
                    Just 0 ->
                        "This is the depedency tab"

                    Just 1 ->
                        "This is the consumer tab"

                    _ ->
                        "Please select a tab"
                )
                    |> Element.text
        }


viewHeader: ServiceView -> Element msg
viewHeader model =
  row [width fill, Background.color headerStyle.bgColor, padding 20] [(text "SLOView"), el [alignRight] (text "(no user)")]

viewFooter: ServiceView -> Element msg
viewFooter _ =
  row footerStyle [(text "copyright 2022 Lutz Behnke"), el [alignRight] (text "About")]
            

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


-- STYLE
type alias ShadowConfig =
    { offset : ( Float, Float )
    , size : Float
    , blur : Float
    , color : Color
    }

type alias StyleConfig =
    { bgColor : Color
    , borderColor : Color
    , shadow : ShadowConfig
    }

headerStyle : StyleConfig
headerStyle = 
    { bgColor = (rgb255 100 200 100)
    , borderColor = (rgb255 50 200 50)
    , shadow = (ShadowConfig (0.1, 0.1) 0.1 0 (rgb255 200 200 200))
    }


footerStyle = 
    [ width fill
    , padding 10
    , Background.color (rgb255 180 230 180)
    , padding 20
    , Font.size 14
    -- , borderColor = (rgb255 50 200 50)
    -- , shadow = (ShadowConfig (0.1, 0.1) 0.1 0 (rgb255 200 200 200))
    ]

cardStyle = 
    [ Border.color (rgb255 50 100 50)
        , Background.color (rgb255 255 255 255)
        , centerX, centerY
        , padding 10
        , Border.width 2
        , Border.shadow (ShadowConfig (4.0, 8.0) 6.0 20.0 (rgba 0 0 0 0.2))
        , Font.size 12
        ]