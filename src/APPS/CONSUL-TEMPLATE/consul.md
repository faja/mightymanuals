- start consul agent in dev mode, and put some data into it
    ```
    consul agent -dev

    cat > nginx.yaml -<<EOT
    ---
    key1: value1
    key2: value2
    key3: value3
    EOT

    consul kv put services/nginx/virtual_server_1 @nginx.yaml
    ```

- create template file and execute consul-template
    ```
    cat > in.tpl -<<EOT
    {{ \$upstreams := sprig_dict }}
    {{- range ls "services/nginx" }}
    {{- range \$k, \$v := .Value | parseYAML }}
    {{- \$_ := sprig_set \$upstreams \$k \$v }}
    {{- end }}
    {{- end }}

    {{- range \$k, \$v := \$upstreams }}
    upstream {{ \$k }} {
      server {{ \$v }}
    }
    {{- end }}
    EOT

    consul-template -template "in.tpl" -once -dry
    ```
