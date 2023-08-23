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
```
reflex -r "\.txt$" echo {}
reflex -r "\.jsonnet$" -- bash -c "render {} && tf-init && tf-apply"
reflex -r "\.yaml$" helm tempalte xxx .
```
