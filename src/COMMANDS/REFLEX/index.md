---

Watch a directory and rerun a command when certain files change

---

- install
    - `go install github.com/cespare/reflex@latest`
    or
    -
        ```
        wget https://github.com/cespare/reflex/releases/download/v0.3.1/reflex_linux_amd64.tar.gz -O /tmp/reflex.tar.gz
        tar -xvf /tmp/reflex.tar.gz
        mv reflex_linux_amd64/reflex ~/bin2
        rm -rf reflex_linux_amd64 /tmp/reflex.tar.gz
        ```

- quick usage
```sh
# any file recursively
reflex -r '.' -- sh -c \
  'echo {} && echo && cd ../../deployments/typesense && \
  helm template typesense typesense --values values.yaml > manifest.yaml'

reflex -r "\.txt$" echo {}
reflex -r "\.jsonnet$" -- bash -c "render {} && tf-init && tf-apply"
reflex -r "\.yaml$" helm tempalte xxx .

# watch single file
reflex -g src/somefile.yaml somecommand

# watch directory
reflex -r '^roles/prometheus' -- sh -c 'cd 01_play_debian12 && task at TAG=prometheus'
```
