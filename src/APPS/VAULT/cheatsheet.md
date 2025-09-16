### dev server
```sh
vault server -dev -dev-root-token-id root
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN="root"
```

### kv basics
```sh
## list
vault kv list -mount=secret            # list all "root" paths under "secret" mount
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
```

### reading data
```sh
# json format + extract a field
vault read -format=json -field data some/path/config | jq -r .CertCa
```

### http api
```sh
# get a secret with curl
curl -k -H "X-Vault-Token: $(cat /secrets/vault_token)" \
  https://127.0.0.1:8200/v1/secret/data/my-secret?version=2
```

### prod server related operations
```sh
vault server -config /path/to/config.hcl

vault operator init

vault operator unseal "<UNSEAL_KEY_1>"  # no vault token is needed
vault operator unseal "<UNSEAL_KEY_2>"  # no vault token is needed
vault operator unseal "<UNSEAL_KEY_3>"  # no vault token is needed

# raft related #################################################################
vault operator raft list-peers
```
