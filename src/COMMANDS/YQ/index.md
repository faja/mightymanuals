---
pretty much the same as `jq`, so please refer to [jq](../JQ/index.md) docs

however, below some handy oneliners:
- helm template and select only one yaml
    ```sh
    helm template ... | yq -r '. | select(.kind == "ConfigMap") | select(.metadata.name == "loki") | .data["config.yaml"]'
    ```
