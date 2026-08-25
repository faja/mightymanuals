#


### release version check

```sh
dnf config-manager --dump-variables
cat /etc/system-release

# and if we bumped release version explicitly with dnf upgrade --releasever=2023.12.20260817
cat /etc/dnf/vars/releasever

# also some details
cat /etc/image-id
```


### repo management

```sh
dnf repolist all --verbose
dnf config-manager --add-repo https://www.example.com/repository.repo
dnf config-manager --set-disabled reponame
```

### search
```
# use `rpm` for local search
rpm -qa
rpm -qf /path/to/file # owner of an installed file

dnf search nginx
dnf info nginx

dnf list available --showduplicates nginx

dnf provides /usr/bin/dig # which package provides a file
```


### install

```sh
dnf install -y nginx
dnf install -y nginx-1.24.0

```

### upgrade

```sh
dnf check-update
dnf -y upgrade

# if we need a specific release version
RELEASEVER=2023.12.20260817
dnf check-update --releasever=${RELEASEVER}
dnf -y upgrade --releasever=${RELEASEVER}
```

### remove

```sh
dnf remove -y nginx
dnf remove --noautoremove nginx # keeps the deps.
```

### cleanup

```sh
dnf autoremove # removes leftover orphans

dnf clean all
dnf makecache
```
