```
#------------------------------------------------------------------------------#
# dev server
vault server -dev
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN="..."
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------#
# kv basics
## list
vault kv list -mount=secret  # list all "root" paths under "secret" mount
vault kv list -mount=secret some/path  # list all keys in "some/path"

## metadata
vault kv metadata get -mount=credentials shared/namespace/fe-web/dhparams

## get
vault kv get -mount=secret some/path/config

## put
vault kv put -mount=secret some/path/config KEY1=VALUE1 KEY2=VALUE2
vault kv put -mount=secret some/path/config @data.json

## patch
vault kv patch -mount=secret some/path/config KEY1=VALUE1 KEY2=VALUE2
vault kv patch -mount=secret some/path/config @data.json
#------------------------------------------------------------------------------#
```

---
reading data
```
# json format + extract a field
vault read -format=json -field data some/path/config | jq -r .CertCa
```

---
http api
```
# get a secret with curl
curl -k -H "X-Vault-Token: $(cat /secrets/vault_token)" https://127.0.0.1:8200/v1/secret/data/my-secret?version=2
```
