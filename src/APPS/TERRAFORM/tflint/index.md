# TLDR

1. install (see instructions below)
2. [terraform language](https://developer.hashicorp.com/terraform/language) plugin is installed and enabled by default, hence:
    - for a single tf config directory execute: `tflint`
    - for a collection of config directories execute: `tflint --recursive`

# Docs

- [github](https://github.com/terraform-linters/tflint)
- [github/user-guide](https://github.com/terraform-linters/tflint/tree/master/docs/user-guide)

### install
- on mac
    ```
    brew install tflint
    ```

- on linux
    ```
    VERSION=0.46.1
    curl -L -o /tmp/tflint.zip https://github.com/terraform-linters/tflint/releases/download/v${VERSION}/tflint_linux_amd64.zip
    unzip /tmp/tflint.zip -d /tmp
    mv /tmp/tflint ~/bin2/tflint
    tflint --version
    ```

### config

- `.tflint.hcl` is the config file
- there are two locations this file is read from: `~/.tflint.hcl` and `${CURRENT_DIR}/.tflint.hcl`
- note! when running with `--recursive` or `--chdir`, the config file will be loaded relative to the module (changed) directory,
  hence always use `--config` option with relative path
    ```
    tflint --recursive --config "$(pwd)/.tflint.hcl"
    ```
- [config options](https://github.com/terraform-linters/tflint/blob/master/docs/user-guide/config.md)

### usage

- just check current tf config
    ```
    tflint
    ```

- check recursively
    ```
    tflint --recursive --config "$(pwd)/.tflint.hcl"
    ```

- by default `tflint` checks only the root module, to "follow" and inspect all
  the module calls
    ```
    tflint --module
    ```

### plugin: aws
- [docs](https://github.com/terraform-linters/tflint-ruleset-aws)
- [configuration](https://github.com/terraform-linters/tflint-ruleset-aws/blob/master/docs/configuration.md)
