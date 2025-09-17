
- [dev server](#dev-server)
- [prod server](#prod-server)
- [reading data](#reading-data)
- [kv basics](#kv-basics)
- [transit](#transit)
- [policy](#policy)
- [misc](#misc)
- [http api](#http-api)



### dev server
```sh
vault server -dev -dev-root-token-id root
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN="root"
```



### prod server
```sh
vault server -config /path/to/config.hcl

export VAULT_ADDR="https://127.0.0.1"
export VAULT_SKIP_VERIF="true"
export VAULT_TOKEN=""

vault operator init
# or to init with 1 seal key
vault operator init -key-shares=1 -key-threshold=1

vault operator unseal "<UNSEAL_KEY_1>"  # no vault token is needed
vault operator unseal "<UNSEAL_KEY_2>"  # no vault token is needed
vault operator unseal "<UNSEAL_KEY_3>"  # no vault token is needed

# raft related #################################################################
vault operator raft list-peers
vault operator raft autopilot state

# audit logging ################################################################
vault audit enable file file_path=stdout
```



### reading data
```sh
# json format + extract a field
vault read -format=json -field data some/path/config | jq -r .CertCa
```



### kv basics
```sh
## enable kv v2
vault secrets enable -path=kv -version=2 kv

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

## simple RO and RW policy for kv store
vault policy write app-rw -<<EOF
path "kv/data/app/*" { capabilities = ["read"] }
path "kv/data/app/*" { capabilities = ["create", "update"] }
# TODO list
EOF
vault token create -orphan -policy=app-rw
```



### transit
```sh
```



### policy
```sh
vault policy write admin -<<EOF
path "*" { capabilities = ["create", "read", "update", "delete", "list", "sudo"] }
EOF
vault tokeen create -policy=admin -explicit-max-ttl=365d -ttl=365d -display-name=admin
```



### misc
```sh
vault kv get -output-policy dev-secrets/creds
```



### http api
```sh
# get a secret with curl
curl -k -H "X-Vault-Token: $(cat /secrets/vault_token)" \
  "https://127.0.0.1:8200/v1/secret/data/my-secret?version=2"

################################################################################
# get health with wget
wget --no-check-certificate --server-response -O - --quiet \
  "https://127.0.0.1/v1/sys/health?standbyok=true"
wget --no-check-certificate --server-response -O - --quiet \
  "https://127.0.0.1/v1/sys/health" # this one gonna return 429 for standby nodes
```

