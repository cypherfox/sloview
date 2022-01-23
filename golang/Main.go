package main

import (
	"fmt"
	"net/http"
)

var testData = `
{
    "version": "v1alpha1",
    "name": "  "Nexus OSS (OCI Registry)",
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
    "consumers": [ 
		/*
        {
            type: <permanent |  eventual | eventualMax | eventualStart | startup; required>
            eventualMax: <time in second until eventualMax has to be refreshed. a value of 0 makes it equal to   
                          permanent; optional>
            endpoint: <URL; required>
            infoEndpoint: <URL, where service info data, for use by sloview, can be read from; optional>
        } 
		*/
    ]
}
}
`

// handler to return generic test data for the sloview client.
func testdata(w http.ResponseWriter, req *http.Request) {

	w.Header().Set("Access-Control-Allow-Origin", "*")

	fmt.Fprintf(w, "F2 \n%v\n", testData)
}

func headers(w http.ResponseWriter, req *http.Request) {

	// This handler does something a little more
	// sophisticated by reading all the HTTP request
	// headers and echoing them into the response body.
	for name, headers := range req.Header {
		for _, h := range headers {
			fmt.Fprintf(w, "%v: %v\n", name, h)
		}
	}
}

func main() {

	// We register our handlers on server routes using the
	// `http.HandleFunc` convenience function. It sets up
	// the *default router* in the `net/http` package and
	// takes a function as an argument.
	http.HandleFunc("/testdata", testdata)

	// Finally, we call the `ListenAndServe` with the port
	// and a handler. `nil` tells it to use the default
	// router we've just set up.
	http.ListenAndServe(":8010", nil)
}
