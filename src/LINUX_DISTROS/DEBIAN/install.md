---

# install on a bare metal

# PRE install steps
- downlad netinstall ios, simply google for `debian __LATEST_CODENAME__ netinstall iso`
  go to the first link and download it
- `dd` iso into usb pendrive
    ```sh
    sudo dd if=debian-13.3.0-amd64-netinst.iso of=/dev/sda bs=16M status=progress oflag=sync
    sudo sync
    ```
- boot a server from the usb pendrive

# INSTALLATION

durgin the installation
- create user `tmp` - for initial setup - gonna be deleted later
- recommended partition layout:
  ```
  /    - 50 GiB
  /var - rest
  ```

# POST install steps

## if RAID
```sh
# NOTE: if there is RAID1, install grub on the other hard drive
sudo grub-install /dev/sda
sudo grub-install /dev/sdb
sudo update-grub
```

## apt config
```sh
cat <<EOT > /etc/apt/apt.conf.d/99norecommends
APT::Install-Recommends "0";
APT::Install-Suggests "0";
EOT
```

## packages

```sh
mkdir /etc/installed_packages
apt list --installed > /etc/installed_packages/20260131_00
```

```sh
apt install --no-install-recommends openssh-server
apt install --no-install-recommends sudo
cat <<EOT > /etc/sudoers.d/tmp
tmp ALL=(ALL:ALL) NOPASSWD:ALL
EOT
```

# POST install via SSH

- ssh key
```sh
mkdir .ssh
cat <<EOT > .ssh/authorized_keys
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII9fLwH69OPoYPdpeGQblTBXcTPsA9nMdFHRlkb1zuBd mc
EOT
chmod 600 .ssh/authorized_keys
```

NOTE: use `tmp` user with `sudo` - by default root login is disabled

```sh
sudo apt install --no-install-recommends \
  ca-certificates \
  curl \
  vim
```
