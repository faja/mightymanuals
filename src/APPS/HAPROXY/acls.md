# ACLs and CONDITIONs

[official docs](http://docs.haproxy.org/2.6/configuration.html#7.1)

## named and anonymous acls
- named
```
...TODO
```
- anonymous
```
...TODO
```

## acl `OR` and `AND`

- `OR` - if we need to have conditions "OR'ed", we repeat acl option with the
         **SAME** name
```
acl api_path_acl path     /api
acl api_path_acl path_beg /api/
# api_path_acl = "path /api" OR "path_beg /api/"
use_backend api-backend-1 if api_path_acl
```
- `AND` - if we need to have conditions "AND'ed", we create acls with
          **DIFFERENT** name
```
acl acl_path path /api
acl acl_host_canary hdr(host) -i canary-xxx.com:8443
# acl_path AND acl_host_canary
use_backend api-canary-backend if acl_path acl_host_canary
```

## acl flags
- `-i` - ignore case
- `-m` - use a specific pattern matching method, eg: `-m reg`
- `-f` - load patterns from a file

## examples
```
# exact match (any of the specified)
{ req.ssl_sni -i devopsninja.xyz devopsninja.info }

# exact match same as above
{ req.ssl_sni -i -m str devopsninja.xyz devopsninja.info }

# regex match (any of the specified)
{ req.ssl_sni -i -m reg ^devopsninja\.xyz$ xx.\.devopsninja.info$ }

# match begining of a string
{ req.hdr(Authorization) -i -m beg bearer }
```
