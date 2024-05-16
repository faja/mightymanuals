
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
          job: containers
          __path__: /var/lib/docker/containers/*/*.log
```
</details>

## system logs: journald + /var/log/
My config for scraping machine system related logs, that is: `journald` and logs
in `/var/log/` directory
<details><summary><span style="color:#33ccff">click</span></summary>

```yaml
TODO
```
</details>


## docker(compose) containers - pure docker no K8S
My config for "simple"  deployment models - where processes are run as docker
containers.
<details><summary><span style="color:#33ccff">click</span></summary>

```yaml
TODO
```
</details>

## K8S
K8S deployment
<details><summary><span style="color:#33ccff">click</span></summary>

```yaml
TODO
```
</details>
