# JSON Objects

# Service View

This is the JSON Structure that is returned by the sloview server, primarily for use by the sloview client.


```
{
    version: < v1; required >
    name: <string, name of the service, primarily used for display purposes; required>
    endpoint: <URL, where service can be consumed; required>
    infoEndpoint: <URL, where service info data, for use by sloview, can be read from; optional>
    dependencies: [ 
        {
            type: <permanent |  eventual | eventualMax | eventualStart | startup; required>
            eventualMax: <time in second until eventualMax has to be refreshed. a value of 0 makes it equal to   
                          permanent; optional>
            endpoint: <URL; required>
            infoEndpoint: <URL, where service info data, for use by sloview, can be read from; optional>
            slos: [
                {
                    - Availability (percentage per Interval (week/month/quarter))
                    - MTTR in seconds
                    - Latency Average per Interval, 90th percentile
                }
            ]
        } 
    ]
    consumers: [ 
        {
            type: <permanent |  eventual | eventualMax | eventualStart | startup; required>
            eventualMax: <time in second until eventualMax has to be refreshed. a value of 0 makes it equal to   
                          permanent; optional>
            endpoint: <URL; required>
            infoEndpoint: <URL, where service info data, for use by sloview, can be read from; optional>
        } 
    ]
}
```