# config handy copy paste snippets

## return static string
[official docs](http://docs.haproxy.org/2.6/configuration.html#http-request%20return)
```
frontend ...
    // this works on both frontend and backend
    http-request return status 200 content-type "text/plain" string "ok"
```


## 403 by default
[official docs](http://docs.haproxy.org/2.6/configuration.html#4.2-http-request%20deny)
```
frontend http
    ...
    default_backend 403

backend 403
    http-request deny status 403 content-type text/plain string 403
    // see also http-request reject
```

## path based routing
```
frontend http
    ...
    use_backend nginx1 if { path /api/data } || { path_beg /api/data/ }
    use_backend nginx2 if { path /api/push } || { path_beg /api/push/ }
    ...
```

## url rewrites

```
##
# remove /api/data path prefix, before sending the request to backend
backend nginx1
    balance roundrobin
    timeout check 1s

    http-request replace-path /api/data(/)?(.*) /\2

    server nginx1 nginx1:80 check

```

## url redirects
TODO

## capture and log a header

- single header
    [official doc](http://docs.haproxy.org/2.6/configuration.html#8.8)
    ```
    frontend http
        capture request header cf-connecting-ip len 15
        capture request header host len 64
        # this is added to httplog by default just before $METHOD in a form of:
        # {$first_capture|$second_capture|...}
    ```

- all headers
    [blog post](https://www.haproxy.com/blog/how-to-log-http-headers-with-haproxy-for-debugging-purposes)
    ```
    frontend http
        log-format "${HAPROXY_HTTP_LOG_FMT} hdrs:%{+Q}[var(txn.req_hdrs)]"
        http-request set-var(txn.req_hdrs) req.hdrs
    ```

## add/set/delete a header
```
frontend http

    # add-header - appends
    # set-header - overrides
    # del-header - deletes

    http-request add-header x-forwarderd-for aaa
    http-request add-header x-forwarderd-for bbb  # sets the header to `aaa,bbb`

    http-request set-header x-forwarderd-for2 ccc # sets the header to just `ccc`

    http-request set-header x-custom-source-ip %[req.hdr(cf-connecting-ip)] if { req.hdr(cf-connecting-ip) -m found }
    http-request set-header x-custom-path %[url]

    http-request del-header x-forwarderd-for # this is case insensitive
```

## log POST rquest body
```
frontend ...
    option http-buffer-request
    declare capture request len 40000
    http-request capture req.body id 0
```

## disable logging completely for a frontend or a backend
```
frontend/backend ...
    no log
```
