---

### working with policies, tokens, roles, etc...

- create admin policy and token
```sh
vault policy write admin -<<EOF
path "*" { capabilities = ["create", "read", "update", "delete", "list", "sudo"] }
EOF

vault token create -orphan -policy=admin -explicit-max-ttl=365d -ttl=365d -display-name=admin
```

- check what capabilites you have against particular path
```sh
vault token capabilities sys/policy
```

- to see what policy is needed for particular operation use `-output-policy`
```sh
vault policy write my-policy ./policy.hcl -output-policy
vault kv get -output-policy dev-secrets/creds
```

- to see what api endpoint a particular vault command is using unser the hood use `-output-curl-string`
```sh
vault policy write my-policy ./policy.hcl -output-curl-string
```
- to check what operations and paths a particular path supports
```sh
vault path-help sys/policy
```

### cert based dynamic tokens

```sh
# create some policy first (see above), which is gonna be attached to requested token

# enable cert auth
vault auth enable cert

# create cert roles
CERT_DNS_SAN="your-service-*.client.consul"
vault write auth/cert/certs/your_service_role \
  certificate="@/secrets/ca_mtls.crt" \
  allowed_dns_sans="${CERT_DNS_SAN}" \
  token_policies="your_service_policy" \
  token_ttl=1h token_max_ttl=4h

# login
vault login -method=cert name=your_service_role

# list roles, and get details about one of them
vault list auth/cert/certs
vault read auth/cert/certs/your_service_role
```
