---

# config

```
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
