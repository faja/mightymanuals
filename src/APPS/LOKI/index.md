
# THIS IS ALL TODO TBH

---


min config
```
auth_enabled: false

server:
  http_listen_port: 3100

common:
  path_prefix: /loki
  storage:
    filesystem:
      chunks_directory: /loki/chunks
      rules_directory: /loki/rules
  ring:
    kvstore:
      store: inmemory

schema_config:
  configs:
    - from: 2024-01-01
      store: boltdb-shipper
      object_store: filesystem
      schema: v12
      index:
        prefix: index_
        period: 24h
```
docker run --rm -t -v $(pwd)/config.yaml:/config.yaml grafana/loki:2.9.3 -config.file=/config.yaml -print-config-stderr 2>&1 | sed '/Starting Loki/q' > loki.defaults.yaml


# run command
```sh
/usr/bin/loki -config.file=/etc/loki/loki.yaml -print-config-stderr
# -log-config-reverse-order # I used to run with this option, but actually,
# I don't like it
```

# config
## single binary
```yaml
##
# this is pretty much my golden config for single binary deployment
# adjusted for version 2.7.3
auth_enabled: false

common:
  path_prefix: /var/lib/loki
  storage:
    filesystem:
      chunks_directory: /var/lib/loki/chunks
      rules_directory: /var/lib/loki/rules
  ring:
    kvstore:
      store: inmemory
  replication_factor: 1

server:
  http_listen_port: 3100
  grpc_listen_port: 9095

ingester:
  chunk_encoding: snappy
  wal:
    flush_on_shutdown: true

schema_config:
  configs:
  - from: "2023-01-15"
    store: boltdb-shipper    # for index
    object_store: filesystem # for chunks
    schema: v12
    index:
      prefix: index_
      period: 24h
    chunks:
      period: 24h

storage_config:
  boltdb_shipper:
    cache_ttl: 72h

compactor:
  retention_enabled: true

limits_config:
  retention_period: 2160h # 90d

chunk_store_config:
  max_look_back_period: 2160h # same as retention_period

tracing:
  enabled: false

analytics:
  reporting_enabled: false
```

## config default values
```sh
cat > /tmp/loki.config <<EOT
schema_config:
  configs:
    - from: 2020-10-24
      store: boltdb-shipper
      object_store: filesystem
      schema: v11
      index:
        prefix: index_
        period: 24h
EOT
export LOKI_VERSION=2.7.3
docker pull grafana/loki:${LOKI_VERSION}
docker run --rm -t -v /tmp/loki.config:/etc/loki/config.yaml grafana/loki:${LOKI_VERSION} -config.file=/etc/loki/config.yaml -print-config-stderr 2>&1 | sed '/Starting Loki/q' > /tmp/loki.yaml
```

# update
- loki documentation contains pretty good [upgrade guide](https://grafana.com/docs/loki/latest/upgrading/)
- quick check for config changes
    ```sh
    export OLD_LOKI=2.6.0
    export NEW_LOKI=2.7.0
    docker pull grafana/loki:${OLD_LOKI}
    docker pull grafana/loki:${NEW_LOKI}

    docker run --rm -t grafana/loki:${OLD_LOKI} -config.file=/etc/loki/local-config.yaml -print-config-stderr 2>&1 | sed '/Starting Loki/q' > loki.${OLD_LOKI}.yaml
    docker run --rm -t grafana/loki:${NEW_LOKI} -config.file=/etc/loki/local-config.yaml -print-config-stderr 2>&1 | sed '/Starting Loki/q' > loki.${NEW_LOKI}.yaml

    vd loki.${OLD_LOKI}.yaml loki.${NEW_LOKI}.yaml
    ```
- [**IMPORTANT**] upgrading is sometimes tricky, so be careful, I once, lost the entire data set (luckly on staging)
