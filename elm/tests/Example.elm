module Example exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)

import Main exposing (..)
import Json.Decode as Decode exposing (decodeString, Error)


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