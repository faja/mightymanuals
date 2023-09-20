---

please TODO this

# packages
```sh
apt-get -y update           #
apt-get -y install procps   # adds `ps` command, useful in docker
```


# certificates
```sh
apt update -y && apt install -y ca-certificates
cp ca.crt /usr/local/share/ca-certificates/ # for some reason must be .crt
update-ca-certificates
```
