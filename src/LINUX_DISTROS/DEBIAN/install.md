---

# install on a bare metal

- downlad netinstall ios, simply google for `debian __LATEST_CODENAME__ netinstall iso`
  go to the first link and download it
- `dd` iso into usb pendrive
    ```sh
    sudo dd if=debian-13.3.0-amd64-netinst.iso of=/dev/sda bs=16M status=progress oflag=sync
    ```
- boot a server from the usb pendrive

# post install steps

## verify RAID boot config
```sh
cat /etc/default/grub | grep GRUB_CMDLINE_LINUX
sudo update-grub
sudo grub-install /dev/sda
sudo grub-install /dev/sdb
```

## apt config
```sh
sudo apt install --no-install-recommends aptitude

sudo tee /etc/apt/apt.conf.d/99norecommends <<EOF
APT::Install-Recommends "0";
APT::Install-Suggests "0";
EOF
```

## packages

```sh
sudo apt install --no-install-recommends openssh-server

sudo apt install --no-install-recommends \
  ca-certificates \
  curl \
  vim
```
