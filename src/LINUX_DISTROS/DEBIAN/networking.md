# networking management system

We do have three options:
- **NetworkManager** - not ideal for servers - to check: `systemctl is-active NetworkManager`
- **systemd-networkd** - clean and nice for servers - to check: `systemctl is-active systemd-networkd`
- **classic /etc/network/interfaces** - this is using `ifupdown` command

# ifupdown
- `/etc/network/interfaces`
    ```ini
    auto enp3s0
    iface enp3s0 inet static
      address 192.168.1.50
      netmask 255.255.255.0
      gateway 192.168.1.1
      dns-nameservers 1.1.1.1 8.8.8.8
    ```
- ```sh
  systemctl restart networking
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
