# step 1 - compose.yaml
first of all we need a compose.yaml file to launch local grafana

[compose.yaml](./compose.yaml):
```
{{#include ./compose.yaml}}
```
[compose.env](./compose.env)
```
{{#include ./compose.env}}
```
[grafana.ini](./grafana.ini)
```
{{#include ./grafana.ini}}
```

# step 2 - start grafana
execute docker compose
```
docker compose --env-file compose.env up --build --remove-orphans --exit-code-from grafana grafana
```

# step 3 - install grafonnet library
go to `dashboards` directory
- [NEED TO BE EXECUTED ONLY ONCE] to initialise jsonnet-bundler package directory
```bash
jb init
jb install https://github.com/grafana/grafonnet-lib/grafonnet
```
- the above will create two files `jsonnetfile.json` and `jsonnetfile.lock.json` these needs to be commited to git
- any future installs (after someone git clone the repo) just:
```bash
jb install
```

# step 4 - render dashboard
```bash
jsonnet -J vendor -o dashboard.json dashboard.jsonnet
```

# step 5 - execute terraform
go to `terraform` directory
```
terraform init
terraform apply
```

# step 6 - profit
go to grafana ui ([http://127.0.0.1:3000/](http://127.0.0.1:3000)) and enjoy
