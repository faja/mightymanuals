---

# package management

## apt-get
```sh
apt-get -y update       # refresh packages db

apt-get -V upgrade      # -V prints versions thats being updated
apt-get -V dist-upgrade #
# difference between upgrade vs dist-upgrade
#  - upgrade - does not install any new packages (or removes old ones)
#  - dist-upgrade - does installs new packages, and removes not needed ones
#                   use this for kernel upgrades

apt-get install ${package_name} # install package
apt-get install ${package_name}=${version_number} # install package in particular version

apt-get remove ${package_name} # removes package, but keeps config files
apt-get purge ${package_name}  # removes package and all related files including config files

apt-get clean           # remove cache etc...
```

## apt-cache
```sh
apt-cache search ${regex}    # search for packages, package name but alos description
apt-cache search -n ${regex} # search for packages, package name only

apt-cache showpkg ${package_name} # show package information
```

## dpkg
```sh
dpkg -l              # list installed packages
dpkg -l iproute2     # show version of a installed package
dpkg -L iproute2     # list files installed by a package
```

# list of packages worth to install
```sh
apt-get -y update           #
apt-get -y install procps    # programs: `ps`, useful in docker
apt-get -y install iproute2  # programs: `ss`, `ip`, `nstat`
apt-get -y install net-tools # programs: `netstat`
```


# certificates
```sh
apt update -y && apt install -y ca-certificates
cp ca.crt /usr/local/share/ca-certificates/ # for some reason must be .crt
update-ca-certificates
```
