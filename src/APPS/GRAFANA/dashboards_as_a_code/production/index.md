# directory structure
- `dashboards_json/` - contains redndered `json` dashboards
- `dashboards_jsonnet/` - contains `jsonnet` dashboards
- `local_development/` - contains stuff for local development: compose, terraform, etc...

# files in local_development
- `compose.yaml`
```
{{#include local_development/compose.yaml}}
```

- `Dockerfile`
```
{{#include local_development/Dockerfile}}
```

- `entrypoint.sh`
```
{{#include local_development/entrypoint.sh}}
```

- `grafana.ini`
```
{{#include local_development/grafana.ini}}
```

- `main.tf`
```
{{#include local_development/main.tf}}
```

- `modules/grafana_dashboards/main.tf`
```
{{#include local_development/modules/grafana_dashboards/main.tf}}
```

# howto remote prometheus data source
```
DOCKER_BRIDGE_IP=$(docker network inspect bridge --format='{{range .IPAM.Config}}{{.Gateway}}{{end}}')
kubectl --context xyzzy --namespace monitoring port-forward --address=${DOCKER_BRIDGE_IP} service/prometheus-prometheus 9090:9090
```
