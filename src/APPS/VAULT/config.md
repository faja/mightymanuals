---

# example of full prod config

```hcl
ui               = false
disable_mlock    = true
plugin_directory = "/vault-plugins"

default_lease_ttl = "768h"  # 32 days
max_lease_ttl     = "8760h" # 1 year

# `api_addr` - is the address exposed outside, that's the one with 8200 default port
api_addr     = "https://${public_address_exposed_outside}:443"
# `cluster_addr` - is the address used internally for cross nods communication
#                  that's the one with 8201 default port
cluster_addr = "https://${node01}:444"
cluster_name = "vault-play"

listener "tcp" {
  address         = ":443"
  cluster_address = ":444"
  tls_cert_file   = "/secrets/server.crt"
  tls_key_file    = "/secrets/server.key"

  # mTLS
  tls_client_ca_file                 = "/secrets/ca_mtls.crt"
  tls_require_and_verify_client_cert = true
  tls_disable_client_certs           = false
}

listener "tcp" {
  # because no mtls here
  address         = ":445"
  tls_cert_file   = "/secrets/server.crt"
  tls_key_file    = "/secrets/server.key"

  telemetry {
    unauthenticated_metrics_access = true
  }
}

backend "raft" {
  path    = "/data/vault-data"
  node_id = "node01"

  retry_join {
    leader_api_addr     = "https://${node01}:443"
    leader_ca_cert_file = "/secrets/ca.crt"

    # mTLS
    leader_client_cert_file   = "/secrets/client.crt"
    leader_client_key_file    = "/secrets/client.key"
  }

  retry_join {
    leader_api_addr     = "https://${node02}:443"
    leader_ca_cert_file = "/secrets/ca.crt"

    # mTLS
    leader_client_cert_file   = "/secrets/client.crt"
    leader_client_key_file    = "/secrets/client.key"
  }

  retry_join {
    leader_api_addr     = "https://${node03}:443"
    leader_ca_cert_file = "/secrets/ca.crt"

    # mTLS
    leader_client_cert_file   = "/secrets/client.crt"
    leader_client_key_file    = "/secrets/client.key"
  }
}

seal "transit" {
  address         = "https://${some_other_vault_cluster}:443"
  token           = "file:///secrets/vault_token"
  disable_renewal = "false"

  key_name        = "unseal_key_name"
  mount_path      = "transit/"
  namespace       = "default"

  tls_skip_verify = "false"
  tls_ca_cert     = "/secrets/ca.crt"
}

telemetry {
  prometheus_retention_time = "30s"
  disable_hostname = true
}
```
