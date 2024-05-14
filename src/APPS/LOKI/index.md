
---
- [loki official docs](https://grafana.com/docs/loki/latest/)
- [loki releases](https://github.com/grafana/loki/releases)

---

docs re version: <span style="color:#ff4d94">**3.0.0**</span>

---

once this page grows, please split it into separate pages
for now LFG single page

---

# run command
How I usually run loki (`-target=all` is optional, that's default value,
but it's nice to be explicit I guess)
```sh
/usr/bin/loki \
  -config.file=/etc/loki/loki.yaml \
  -print-config-stderr \
  -target=all
```



# CONFIG and DEPLOYMENT MODES

## check default config

<details><summary><span style="color:#33ccff">click</span></summary>

```sh
cat > /tmp/loki.config <<EOT
common:
  path_prefix: /tmp/loki
schema_config:
  configs:
    - from: 2024-05-15
      schema: v13
      store: tsdb
      object_store: filesystem
      index:
        prefix: index_
        period: 24h
EOT
export LOKI_VERSION=3.0.0
docker pull grafana/loki:${LOKI_VERSION}
docker run --rm -t -v /tmp/loki.config:/etc/loki/config.yaml grafana/loki:${LOKI_VERSION} -config.file=/etc/loki/config.yaml -print-config-stderr 2>&1 | sed '/Starting Loki/q' > /tmp/loki.yaml
```
</details>


## bare minimum
Bare minimum config to start loki. SEE playdir: `mightyplay/loki/00_play`
<details><summary><span style="color:#33ccff">click</span></summary>

```yaml
---
auth_enabled: false
tracing:
  enabled: false
analytics:
  reporting_enabled: false

server:
  http_listen_port: 3100 # this is default, here just for reference
  grpc_listen_port: 9095 # this is default, here just for reference

common:
  ring:
    kvstore:
      store: inmemory
  replication_factor: 1
  path_prefix: /tmp/loki

schema_config:
  configs:
    - from: 2024-05-01
      schema: v13
      store: tsdb
      object_store: filesystem
      index:
        prefix: index_
        period: 24h
```
</details>

## single binary mode
<details><summary><span style="color:#33ccff">click</span></summary>

```yaml
ingester:
  chunk_encoding: snappy
```
</details>

## SSD mode

TODO

## microservices mode

TODO
