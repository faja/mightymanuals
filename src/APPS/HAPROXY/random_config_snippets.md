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

# url redirects
