# atlantis

## server config options
(for all availalbe options go to [official documentation](https://www.runatlantis.io/docs/server-configuration.html))
```bash
ATLANTIS_PORT=...                        # port
ATLANTIS_ATLANTIS_URL=...                # ulr to 
ATLANTIS_DATA_DIR=...                    # default `~/.atlantis`, where atlantis keeps data
ATLANTIS_CHECKOUT_STRATEGY=merge         # default `branch`, IMO this should be merge

ATLANTIS_REPO_CONFIG=...                 # path to repo config file
ATLANTIS_REPO_ALLOWLIST=...              # what repos are allowed, see documentation for a syntax

ATLANTIS_DEFAULT_TF_VERSION=...          # set default terraform version to be used, if not specified by a repo

ATLANTIS_ENABLE_DIFF_MARKDOWN_FORMAT=... # consider to enable

ATLANTIS_SSL_CERT_FILE=...               # if we want to terminate ssl on the atlantis itself
ATLANTIS_SSL_KEY_FILE=...                # same

ATLANTIS_WEB_BASIC_AUTH=true
ATLANTIS_WEB_USERNAME=yourUsername
ATLANTIS_WEB_PASSWORD=yourPassword
```

## server side config
[official documentation](https://www.runatlantis.io/docs/server-side-repo-config.html#example-server-side-repo)

important ones:
```bash
allowed_overrides: [workflow]
allow_custom_workflows: true
```

## repo level config (atlantis.yaml)
[official documentation](https://www.runatlantis.io/docs/repo-level-atlantis-yaml.html#example-using-all-keys)
