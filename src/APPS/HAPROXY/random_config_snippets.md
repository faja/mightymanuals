# config handy copy paste snippets

## 403 by default
```
frontend http
    ...
    default_backend 403

backend 403
    http-request deny status 403 content-type text/plain string 403
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

[official doc](http://docs.haproxy.org/2.6/configuration.html#8.8)

```
frontend http
    capture request header cf-connecting-ip len 15
    capture request header host len 64
    # this is added to httplog by default just before $METHOD in a form of:
    # {$first_capture|$second_capture|...}
```

## add/set a header
```
frontend http

    # add-header - appends
    # set-header - overrides

    http-request add-header x-forwarderd-for aaa
    http-request add-header x-forwarderd-for bbb  # sets the header to `aaa,bbb`

    http-request set-header x-forwarderd-for2 ccc # sets the header to just `ccc`

    http-request set-header x-custom-source-ip %[req.hdr(cf-connecting-ip)] if { req.hdr(cf-connecting-ip) -m found }
    http-request set-header x-custom-path %[url]
```
