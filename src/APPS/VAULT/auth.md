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
