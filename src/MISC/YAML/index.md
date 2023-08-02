# anchors

```yaml
#------------------------------------------------------------------------------#
# how to test?
cat a.yaml | yq -yy


#------------------------------------------------------------------------------#
# string to string
string_key1: &string_key1 some value of key1
string_key2: *string_key1


#------------------------------------------------------------------------------#
# array to array
array_key1: &array_key1
  - VERSION: 3.11
    DIGEST: sha256:1d681e94835cb783dd717425aa8dff766148bcd6cee0417b8d3a746f0201dd6d
  - VERSION: 3.11-dev
    DIGEST: sha256:b330aa1cd9a0dd5b6f68aad00cb67e8e03f02e6c16eabf9f065a03bb4b2301cd

array_key2: *array_key1


#------------------------------------------------------------------------------#
```
