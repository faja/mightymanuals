# stick-table

`stick-table` is used for multiple different things, one of the common usage
is rate limiting


full format:
```
stick-table type {ip | integer | string [len <length>] | binary [len <length>]}
            size <size> [expire <expire>]
            [nopurge] [peers <peersect>] [srvkey <srvkey>]
            [store <data_type>]*
```

short:
```
stick-table type <type> size <size> expire <duration> store <data_type>
```

- type
    - `type string [len <length>]` - by default length is 32 characters
    - `type binary [len <length>]` - by default length is 32 bytes
    - `type integer` -
    - `type ip`
    - `type ipv6`

- size <size> - number of entries in a table, supports suffixes "k", "m", "g", approx size per entry is 50 bytes + size of a string if any

- expire <duration> - expire old entries if not touched for <duration>

- store <data_type> - defines what actualy we want to store as a "value" (key is the thing defined by `type` keyword)
    - `store http_req_rate(60s)` - store the rate of requests in a floating window of 60s
    - `store conn_rate(60s)` - store tcp connection rate in a floating window of 60s
    - `store conn_cur` - store number of current connections
    - see official documentation for all...

## how to use it, quick how to

```
frontend ...
    stick-table type ip size 1m expire 60s store http_req_rate(60s)
    http-request track-sc0 src
    http-request deny status 429 hdr x-rate-limit exceeded content-type application/json string "{\"error\": \"rate limit exceeded\"}" if { sc_http_req_rate(0) gt 600 }
```


Generally there are THREE steps:
1. firstly, we need to define our stick-table, usually it is defined in the
`frontend` section, where we will be using it
```
stick-table type ip size 1m expire 60s store http_req_rate(60s)
```
- this is a stick table of type `ip` - that means our keys will be ip addresses
- we can store up to 1 milion entries in it
- and we will be tracking http requests rate in a floating window of 60 seconds

2. secondly, we need to track the requests, which means for each request going
through haproxy we will be adding a counter to an stick table entry
```
http-request track-sc0 src
```
- `sc0` = sticky counter 0 - we will be using sticky counter 0 to track ip addresses
    this number `0` is important as it will be used in next step

3. last step is to do something with the counter, usually deny request or drop
  a connection
```
http-request deny status 429 hdr x-rate-limit exceeded content-type application/json string "{\"error\": \"rate limit exceeded\"}" if { sc_http_req_rate(0) gt 600 }
```
- we are sending 429 response if requests rate is greater than 600r/60s
- important thing is `sc_http_req_rate(0)` , where
  - `sc_` - just a prefix (sticky counter)
  - `http_req_rate` - is the store data type of sticky-table (point 1.)
  - `0` is the sticky counter number used in TRACK directive (point 2.)


## stick table metrics
```sh
echo show table ${TABLE_NAME} | socat stdio ${STATS_SOCKET}
```

# rate limiting examples

## 1. ip based http requests rate limit
```
frontend ...
    # 60 requests in a floating window of 60 seconds
    stick-table type ip size 1m expire 60s store http_req_rate(60s)
    http-request track-sc0 src
    http-request deny status 429 hdr x-rate-limit exceeded content-type application/json string "{\"error\": \"rate limit exceeded\"}" if { sc_http_req_rate(0) gt 60 }
```

## 2. Authorization header based, http requests rate limit
```
frontend ...
    stick-table type string len 512 size 1m expire 60s store http_req_rate(60s)
    http-request track-sc0 req.hdr(Authorization)
    http-request deny status 429 hdr x-rate-limit exceeded content-type application/json string "{\"error\": \"rate limit exceeded\"}" if { sc_http_req_rate(0) gt 60 }
    # but if there is no Authorization header no limit is applied
    use_backend unauth unless { req.hdr(Authorization) -m found }
```

## 3. TCP rate limiting, ip based, both: current connections and connection rate
```
frontend ...
    stick-table type ip size 1m expire 1m store conn_cur,conn_rate(1m)
    tcp-request connection track-sc0 src
    #tcp-request content reject if { sc_conn_cur(0) gt 1 } || { sc_conn_rate(0) gt 5 }   # this is logged in tcplog
    tcp-request connection reject if { sc_conn_cur(0) gt 1 } || { sc_conn_rate(0) gt 5 } # this is not logged in tcplog
```

## 4. rate limiting based on two differet counters
```
backend st-auth-bearer
    stick-table type string len 512 size 1m expire 10s store http_req_rate(10s)
backend st-auth-pow
    stick-table type string len 512 size 1m expire 10s store http_req_rate(10s)

frontend ...
    http-request track-sc0 req.hdr(Authorization) table st-auth-bearer if { req.hdr(Authorization) -i -m beg bearer }
    http-request track-sc1 req.hdr(Authorization) table st-auth-pow    if { req.hdr(Authorization) -i -m beg pow }
    http-request deny status 429 hdr x-rate-limit exceeded content-type application/json string "{\"error\": \"rate limit exceeded\"}" if { sc_http_req_rate(0) gt 10 }
    http-request deny status 429 hdr x-rate-limit exceeded content-type application/json string "{\"error\": \"rate limit exceeded\"}" if { sc_http_req_rate(1) gt 2 }
```

# links

- [http://docs.haproxy.org/2.6/configuration.html#stick-table](http://docs.haproxy.org/2.6/configuration.html#stick-table)
- [https://www.haproxy.com/blog/introduction-to-haproxy-stick-tables/](https://www.haproxy.com/blog/introduction-to-haproxy-stick-tables/)
- [https://www.haproxy.com/blog/four-examples-of-haproxy-rate-limiting/](https://www.haproxy.com/blog/four-examples-of-haproxy-rate-limiting/)
- [https://www.haproxy.com/blog/application-layer-ddos-attack-protection-with-haproxy/](https://www.haproxy.com/blog/application-layer-ddos-attack-protection-with-haproxy/)
- [https://www.haproxy.com/blog/preserve-stick-table-data-when-reloading-haproxy/](https://www.haproxy.com/blog/preserve-stick-table-data-when-reloading-haproxy/)
- [https://www.haproxy.com/blog/bot-protection-with-haproxy/](https://www.haproxy.com/blog/bot-protection-with-haproxy/)
