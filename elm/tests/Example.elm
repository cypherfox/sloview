module Example exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)

import Main exposing (..)
import Json.Decode as Decode exposing (decodeString, Error)
import Json.Encode as Encode exposing (encode)


parseSLO : Test
parseSLO =
    describe "parse SLO JSON structure"
        [ test "Availability" <|
            \_ -> 
                let 
                    expected = (SLO "Availability" "month" 96)
                    json = """
                        {"kind": "Availability", "interval": "month", "targetValue": 96}
                        """
                in
                Expect.equal (Ok expected) (Decode.decodeString sloDecoder json)
        , test "MTTR" <|
            \_ -> 
                let 
                    expected = (SLO "MTTR" "month" 100)
                    json = """
                        {"kind": "MTTR", "interval": "month", "targetValue": 100}
                        """
                in
                Expect.equal (Ok expected) (Decode.decodeString sloDecoder json)
        , test "Latency" <|
            \_ -> 
                let 
                    expected = (SLO "Latency" "month" 100)
                    json = """
                        {"kind": "Latency", "interval": "month", "targetValue": 100}
                        """
                in
                Expect.equal (Ok expected) (Decode.decodeString sloDecoder json)
        , test "week" <|
            \_ -> 
                let 
                    expected = (SLO "MTTR" "week" 100)
                    json = """
                        {"kind": "MTTR", "interval": "week", "targetValue": 100}
                        """
                in
                Expect.equal (Ok expected) (Decode.decodeString sloDecoder json)
        , test "quarter" <|
            \_ -> 
                let 
                    expected = (SLO "MTTR" "quarter" 100)
                    json = """
                        {"kind": "MTTR", "interval": "quarter", "targetValue": 100}
                        """
                in
                Expect.equal (Ok expected) (Decode.decodeString sloDecoder json)
        ]

parseDependency =
    describe "parse dependency JSON structure"
        [ test "eventualMax" <|
            \_ -> 
                let 
                    expected = ( Dependency 
                                   "eventualMax" 
                                   300 
                                   "https://ns1.example.com/" 
                                   "https://cooldudes.example.com/serviceInfo/dns" 
                                   [ (SLO "Availability" "month" 96)
                                   , (SLO "MTTR" "month" 100)
                                   , (SLO "Latency" "month" 100)
                                   ]
                                )
                    json = """
                        {
                           "kind": "eventualMax",
                           "eventualMax": 300,
                           "endpoint": "https://ns1.example.com/",
                           "infoEndpoint": "https://cooldudes.example.com/serviceInfo/dns",
                           "slos": [
                               {
               					"kind": "Availability",
               					"interval": "month",
               					"targetValue": 96
               				   },
                               {
               					"kind": "MTTR",
               					"interval": "month",
               					"targetValue": 100
                               },
                               {
               					"kind": "Latency",
               					"interval": "month",
               					"targetValue": 100
                               }
                           ]
                        }
                        """
                in
                Expect.equal (Ok expected) (Decode.decodeString dependencyDecoder json)
        , test "permanent" <|
            \_ -> 
                let 
                    expected = ( Dependency 
                                   "permanent" 
                                   0 
                                   "https://ns1.example.com/" 
                                   "https://cooldudes.example.com/serviceInfo/dns" 
                                   []
                                )
                    json = """
                        {
                           "kind": "permanent",
                           "endpoint": "https://ns1.example.com/",
                           "infoEndpoint": "https://cooldudes.example.com/serviceInfo/dns",
                           "slos": []
                        }
                        """
                in
                Expect.equal (Ok expected) (Decode.decodeString dependencyDecoder json)
            ]


parseServiceView =
    describe "parse serviceView JSON structure"
        [ test "basic" <|
            \_ -> 
                let 
                    expected = ( ServiceView
                                    "v1alpha1"
                                    "Nexus OSS (OCI Registry)"
                                    "https://nexus.example.com/"
                                    "https://cooldudes.example.com/serviceInfo/nexus"
                                    [ ( Dependency 
                                        "eventualMax" 
                                        300 
                                        "https://ns1.example.com/" 
                                        "https://cooldudes.example.com/serviceInfo/dns" 
                                        [ (SLO "Availability" "month" 96)
                                        , (SLO "MTTR" "month" 100)
                                        , (SLO "Latency" "month" 100)
                                        ]
                                      )
                                    , ( Dependency 
                                        "permanent" 
                                        0
                                        "https://mysqldb.example.com/" 
                                        "https://axis-of-evil.example.com/services/mysql" 
                                        [ (SLO "Availability" "month" 96)
                                        , (SLO "MTTR" "month" 100)
                                        , (SLO "Latency" "month" 100)
                                        ]
                                      )
                                    ]
                                    []
                                )
                    json = """
                       {
                           "version": "v1alpha1",
                           "name": "Nexus OSS (OCI Registry)",
                           "endpoint": "https://nexus.example.com/",
                           "infoEndpoint": "https://cooldudes.example.com/serviceInfo/nexus",
                           "dependencies": [ 
                               {
                                   "kind": "eventualMax",
                                   "eventualMax": 300,
                                   "endpoint": "https://ns1.example.com/",
                                   "infoEndpoint": "https://cooldudes.example.com/serviceInfo/dns",
                                   "slos": [
                                       {
                       					"kind": "Availability",
                       					"interval": "month",
                       					"targetValue": 96
                       				   },
                                       {
                       					"kind": "MTTR",
                       					"interval": "month",
                       					"targetValue": 100
                                       },
                                       {
                       					"kind": "Latency",
                       					"interval": "month",
                       					"targetValue": 100
                                       }
                                   ]
                               } ,
                               {
                                   "kind": "permanent",
                                   "endpoint": "https://mysqldb.example.com/",
                                   "infoEndpoint": "https://axis-of-evil.example.com/services/mysql",
                                   "slos": [
                                       {
                       					"kind": "Availability",
                       					"interval": "month",
                       					"targetValue": 96
                                       },
                                       {
                       					"kind": "MTTR",
                       					"interval": "month",
                       					"targetValue": 100
                                       },
                                       {
                       					"kind": "Latency",
                       					"interval": "month",
                       					"targetValue": 100
                                       }
                                   ]
                               } 
                           ],
                           "consumers": []
                        }
                    """
                    in
                    Expect.equal (Ok expected) (Decode.decodeString serviceViewDecoder json)
        ]

