---

# cargo usage
todo

# cargo config

- project level `${PROJECT_DIR}/.cargo/config.toml`
- user level `~/.cargo/config.toml`

## registries
custom/private registry can be specified in cargo `config.toml` (project or user level)

```toml
[registries]
registry-name = { index = "sparse+https://.../" }

[registry]
global-credential-providers = ["cargo:token"]
```

to authenticate we can use different methods aka providers, default one `cargo:token`
is using file `~/.cargo/credentials.toml` (which in turn is populated by running
`cargo login --registry registry-name`, the file looks like:

```toml
[registries.registry-name]
token = "..."
```

custom "exec" provider can be configured with `token-fron-stdout` provider, as follows:

```toml
[registry]
global-credential-providers = ["cargo:token-from-stdout cat /home/mc/.my.cargo.token"]

[registries.my-private]
index = "sparse+https://registry.example.com/index/"
```
