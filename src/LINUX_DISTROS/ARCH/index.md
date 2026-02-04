
---

- [pacman](./pacman.md)
- [custom keyboard](./custom_keyboard.md)

---

TODO

post install

- vagrant
- virtualbox
- virtualbox-host-modules-arch

packages installed manually via AUR:
- vagrant - needed latest version - https://aur.archlinux.org/packages/vagrant
- dropbox - only via AUR - https://aur.archlinux.org/packages/dropbox

---

# networking

- static ip
    ```sh
    ip a add 192.168.1.2/24 dev enp0s20f0u5u2u4
    ip link set dev enp0s20f0u5u2u4 up

    ```



---

# virtualization: libvirt + qemu

https://wiki.archlinux.org/title/Libvirt#Set_up_authentication
https://jamielinux.com/docs/libvirt-networking-handbook/index.html
https://registry.terraform.io/providers/dmacvicar/libvirt/latest/docs/resources/pool


### installation and config
```sh
sudo su -

pacman -S libvirt qemu
usermod -aG libvirt mc  # add `mc` user to `libvirt` group, for easier management

cp /etc/libvirt/libvirtd.conf{,.ori}
cat <<EOT > /etc/libvirt/libvirtd.conf
unix_sock_group = "libvirt"
unix_sock_ro_perms = "0770"
unix_sock_rw_perms = "0770"
auth_unix_ro = "none"
auth_unix_rw = "none"
EOT

systemctl start libvirtd.service
systemctl start virtlogd.service
```

### volumes
- `default` pool is created and enabled by default
- this is `dir` type with target `/var/lib/libvirt/images`
- run `sudo virsh pool-dumpxml default` to see more details

### networking
