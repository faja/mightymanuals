# 

# config
TODO

    ```yaml

    # compactor component
    #   periodically compacts index shards to more performant forms
    compactor:
        working_directory: /var/lib/loki/boltdb-shipper-compactor

    tracing:
        enabled: false
    analytics:
        reporting_enabled: false
    ```

# update
- loki documentation contains pretty good [pgrade guide](https://grafana.com/docs/loki/latest/upgrading/)
- quick check for config changes
    ```sh
    export OLD_LOKI=2.5.0
    export NEW_LOKI=2.6.0
    docker pull grafana/loki:${OLD_LOKI}
    docker pull grafana/loki:${NEW_LOKI}

    docker run --rm -t grafana/loki:${OLD_LOKI} -config.file=/etc/loki/local-config.yaml -print-config-stderr 2>&1 | sed '/Starting Loki/q' > loki.${OLD_LOKI}.yaml
    docker run --rm -t grafana/loki:${NEW_LOKI} -config.file=/etc/loki/local-config.yaml -print-config-stderr 2>&1 | sed '/Starting Loki/q' > loki.${NEW_LOKI}.yaml

    vd loki.${OLD_LOKI}.yaml loki.${NEW_LOKI}.yaml
    ```
