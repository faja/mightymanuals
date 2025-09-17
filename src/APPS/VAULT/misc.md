---

# how to configure longer leases for a token auth method

best place to configure it, is configuration file:
```hcl
default_lease_ttl = "768h"  # 32 days
max_lease_ttl     = "8760h" # 1 year
```

it is also possible to configure it per auth method,
or if we do not want to modify config file for some reason

```sh
# list
vault auth list
# or
vault read sys/auth

# read current config
vault read sys/auth/token/tune
# tune
vault auth tune -max-lease-ttl=8760h token
```
