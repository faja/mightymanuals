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
- for my production setup - see [mightyplay - 01_prod_one](https://github.com/faja/mightyplay/tree/master/grafana/dashboards_as_a_code/01_prod_one)

# jsonnet snippets
- [jsonnet snippets](./jsonnet_snippets/index.md) - TODO NEXT

# links
- rendered api docs: [grafana.github.io/grafonnet](https://grafana.github.io/grafonnet/index.html)
- github: [github.com/grafana/grafonnet](https://github.com/grafana/grafonnet)
