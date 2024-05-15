
---

- [promtail official docs](https://grafana.com/docs/loki/latest/send-data/promtail/configuration/)

---

- docs re version: <span style="color:#ff4d94">**3.0.0**</span>

---

# run command
How I usually run promtail
```sh
promtail -config.file=/promtail.yaml -print-config-stderr
```

# CONFIG and DEPLOYMENT MODES

## bare minimum
Bare minimum config to start promtail. SEE playdir: `mightyplay/loki/00_play`
<details><summary><span style="color:#33ccff">click</span></summary>

```yaml
---
tracing:
  enabled: false

server:
  http_listen_port: 3100
  grpc_listen_port: 9095

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://loki:3100/loki/api/v1/push
    external_labels:
      nodename: xyzzy

scrape_configs:
  - job_name: containers
    static_configs:
      - labels:
          __path__: /var/lib/docker/containers/*/*.log
```
</details>
