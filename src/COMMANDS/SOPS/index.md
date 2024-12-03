---

[sops](https://github.com/getsops/sops)

```sh
sops -e -i some_file.yaml      # encrypt inplace
sops -d some_file.yaml

sops updatekeys some_file.yaml # add or remove keys based on `creaation_rules` config
# but it's a good practice to rotate key if we are removing some keys
sops rotate -i --rm-age age1...keyxxx some_file.yaml  # rotate keys, inplace
sops rotate -i some_file.yaml  # rotate keys, inplace
```

## sops and age
- generate age key for sops
    ```sh
    mkdir -p ~/.config/sops/age/
    age-keygen -o ~/.config/sops/age/keys.txt
    chmod 700 -R ~/.config/sops
    chmod 400 ~/.config/sops/age/keys.txt
    ```
- `.sops.yaml`
    ```yaml
    ---
    creation_rules:
      - age: >-
          age1...key1,
          age1...key2
    ```
- to decrypt sops is using key located in `~/.config/sops/age/keys.txt` by default,
  this can be changed with `SOPS_AGE_KEY_FILE` env variable
- run `updatekeys` when or `rotate` when adding/removing keys
    ```sh
    sops updatekeys some_file.yaml
    # or
    sops rotate -i --add-age age1...key1 some_file.yaml
    sops rotate -i --rm-age  age1...key1 some_file.yaml
    ```
- see also [age](./../AGE/index.md) for some more details about `age`

