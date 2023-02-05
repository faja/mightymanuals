- start vault agent in dev mode, and put some data into it
    ```
    vault server -dev
    export VAULT_ADDR='http://127.0.0.1:8200'
    export VAULT_TOKEN="..."

    cat > config.json -<<EOT
    {
        "all": {
            "DB_PASS": "secccc"
        },
        "worker1": {
            "XXX": "ok",
            "YYY": "ok2"
        }
    }
    EOT

    vault kv put -mount=secret config @config.json
    ```

- create template file and execute consul-template
    ```
    cat > in.tpl -<<EOT
    {{ with secret "secret/data/config" }}
    {{ range \$k, \$v := .Data.data.all }}
    {{ \$k }} = {{ \$v | toJSON }}
    {{ end }}
    {{ range \$k, \$v := .Data.data.worker1 }}
    {{ \$k }} = {{ \$v | toJSON }}
    {{ end }}
    {{ end }}
    EOT

    consul-template -vault-renew-token=false -template "in.tpl" -once -dry
    ```
