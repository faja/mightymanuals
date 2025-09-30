# getting started
- install `jsonnet` and `jb`
    ```sh
    go install github.com/google/go-jsonnet/cmd/jsonnet@latest
    go install github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb@latest
    ```

- create and init project dir
    ```sh
    mkdir myawesomedashboards && cd myawesomedashboards
    jb init
    jb install github.com/grafana/grafonnet/gen/grafonnet-latest@main
    # or version specific
    jb install github.com/grafana/grafonnet/gen/grafonnet-v11.4.0@main
    ```

- create and compile your first dashboard
    ```
    cat > dashboard.jsonnet <<EOT
    local grafonnet = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
    grafonnet.dashboard.new('My Dashboard')
    EOT

    jsonnet -J vendor -o dashboard.json dashboard.jsonnet
    ```

- import json dashboard to grafana, how? it's up to you, but terraform is a good choice

# next steps
- for a quick start example - see [mightyplay - 00_quick_one](https://github.com/faja/mightyplay/tree/master/grafana/dashboards_as_a_code/00_quick_one)
- [production (one of my projects)](./production/index.md)

# jsonnet snippets
- [jsonnet snippets](./jsonnet_snippets/index.md)

# links
- [https://github.com/grafana/grafonnet-lib](https://github.com/grafana/grafonnet-lib)
- [https://grafana.github.io/grafonnet-lib/](https://grafana.github.io/grafonnet-lib/)
- [https://github.com/google/go-jsonnet](https://github.com/google/go-jsonnet)
- [https://github.com/jsonnet-bundler/jsonnet-bundler](https://github.com/jsonnet-bundler/jsonnet-bundler)
- [https://github.com/adamwg/grafana-dashboards](https://github.com/adamwg/grafana-dashboards)
