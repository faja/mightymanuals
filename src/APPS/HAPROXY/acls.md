---
ACLs and CONDITIONs

### acl flags
- `-i` - ignore case
- `-m` - use a specific pattern matching method, eg: `-m reg`
- `-f` - load patterns from a file

ex:
```
{ req.ssl_sni -i devopsninja.xyz devopsninja.info }                 # exact match (any of the specified)
{ req.ssl_sni -i -m str devopsninja.xyz devopsninja.info }          # exact match same as above
{ req.ssl_sni -i -m reg ^devopsninja\.xyz$ xx.\.devopsninja.info$ } # regex match (any of the specified)
```
