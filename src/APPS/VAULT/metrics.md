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

# metrics worth to monitor

- [https://developer.hashicorp.com/vault/docs/internals/telemetry/key-metrics](https://developer.hashicorp.com/vault/docs/internals/telemetry/key-metrics)
- [https://developer.hashicorp.com/vault/docs/internals/telemetry/metrics](https://developer.hashicorp.com/vault/docs/internals/telemetry/metrics)


```txt
vault_core_active                   - returns `1` if a node is follower
vault.core.handle_request           - Time required to complete a non-login request
vault.core.in_flight_requests       - Number of requests currently in progress
vault.core.response_status_code     - Number of responses issued by the local node

vault.core.handle_login_request     - Time required to complete a login request
vault.token.creation                - Number of service or batch tokens created
vault.token.count                   - updated every 10mins
vault.quota.lease_count.counter     - Total number of leases associated with the named quota rule
vault.quota.lease_count.max         - Maximum number of leases allowed by the named quota rule

vault.route.create.{MOUNTPOINT}     - Time required to send a create request to the backend and for the backend to complete the operation for the given mount point
vault.route.delete.{MOUNTPOINT}     - same but for delte
vault.route.list.{MOUNTPOINT}       - same but for list
vault.route.read.{MOUNTPOINT}       - same but for read

vault.runtime.alloc_bytes           - Space currently allocated to Vault processes
vault.runtime.free_count            - Number of freed objects
vault.runtime.gc_pause_ns           - Time required to complete the last garbage collection run
vault.runtime.heap_objects          - Total number of objects on the heap in memory (The vault.runtime.heap_objects metric is a good memory pressure indicator. We recommend monitoring vault.runtime.heap_objects to establish an accurate baseline and thresholds for alerting on the health of your Vault installation.)
vault.runtime.malloc_count          - Total number of allocated heap objects in memory
vault.runtime.num_goroutines        - Total number of Go routines running in memory (The vault.runtime.num_goroutines metric is a good system load indicator. We recommend monitoring vault.runtime.num_goroutines to establish an accurate baseline and thresholds for alerting on the health of your Vault installation.)
vault.runtime.sys_bytes             - Total number of bytes allocated to Vault (The total number of allocated system bytes includes space currently used by the heap plus space that has been reclaimed by, but not returned to, the operating system.)
vault.runtime.total_gc_pause_ns     - The total garbage collector pause time since Vault was last started
vault.runtime.total_gc_runs         - The total number of garbage collection runs since Vault was last started

vault.core.leadership_lost          - Total time that a high-availability cluster node last maintained leadership
vault.core.leadership_setup_failed  - Time taken by the most recent leadership setup failure

vault.expire.num_leases

vault.<STORAGE>.get
vault.<STORAGE>.put
vault.<STORAGE>.list
vault.<STORAGE>.delete

vault.ha.rpc.client.echo            - Time taken to send an echo request from a standby to the active node (also emitted by perf standbys)
vault.ha.rpc.client.forward         - Time taken to forward a request from a standby to the active node
vault.autopilot.healthy             - Indicates whether all nodes are healthy
```
