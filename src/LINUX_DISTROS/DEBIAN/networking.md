# networking management system

We do have three options:
- **classic /etc/network/interfaces** - this is using `ifup` and `ifdown` commands - to check: `systemctl is-active networking`
- **systemd-networkd** - clean and nice for servers - to check: `systemctl is-active systemd-networkd`
- **NetworkManager** - not ideal for servers - to check: `systemctl is-active NetworkManager`

# ifupdown

`man 5 interfaces`

## tldr; static ip
- `/etc/network/interfaces`
    ```ini
    auto lo
    iface lo inet loopback

    auto enp3s0
    iface enp3s0 inet static
      address 192.168.1.50/24
      gateway 192.168.1.1
      dns-nameservers 1.1.1.1 8.8.8.8
    ```
- ```sh
  systemctl restart networking
  ```
## default, after install
- `/etc/network/interfaces`
    ```ini
    source /etc/network/interfaces.d/*

    auto lo
    iface lo inet loopback

    allow-hotplug enp3s0f0
    iface enp3s0f0 inet dhcp
    ```

## how to restart networking
```sh
systemctl restart networking
# or
ifdown enp3s0f0 && ifup enp3s0f0
```

# systemd-networkd
- `/etc/systemd/network/10-static.network`
  ```ini
  [Match]
  Name=enp3s0

  [Network]
  Address=192.168.1.50/24
  Gateway=192.168.1.1
  DNS=1.1.1.1
  DNS=8.8.8.8
  ```
- ```sh
  systemctl enable systemd-networkd
  systemctl restart systemd-networkd
  ```
- ```sh
  networkctl status enp3s0
  ```

# NetworkManager
Not gonna cover, this is for desktop environments.
