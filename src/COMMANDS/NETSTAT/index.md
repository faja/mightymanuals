---
```sh
apt-get -y install net-tools
```

```sh
netstat -i  # print interface statistics, RX/TX: packets, errors, drops
            # but pretty much the same as cat /proc/net/dev
netstat -s  # print network stack statistics, really nice one for extended stats
            # like "packets pruned from receive queue because of socket buffer overrun"

# really only these two should be used
# for socket stats please use `ss`
```
