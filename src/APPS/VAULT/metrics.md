---

# config

```hcl
telemetry {
  prometheus_retention_time = "30s"
  disable_hostname = true
}

listener "tcp" {
  // allow unauthenticated access to metrics endpoint /v1/sys/metrics
  telemetry {
    unauthenticated_metrics_access = true
  }
}
```

```sh
wget --no-check-certificate --server-response -O - --quiet \
  --header "Accept: prometheus/telemetry" \
  "https://127.0.0.1/v1/sys/metrics"

# or instead of using header
  "https://127.0.0.1/v1/sys/metrics?format=prometheus"
```
