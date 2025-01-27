---

- [ring buffers (nic buffers)](#ring-buffers)
- [socket buffers, tcp_mem, tcp_rmem, tcp_wmem](#socket-buffers)

---

### ring buffers

```sh
# show statistics, check rx,tx ring buffer drops
ethtool -S eth0 | grep drop

# check current setting
ethtool -g eth0         # -g == --show-ring

# set new queue length for rx,tx
ethtool -G eth0 rx N    # -G == --set-ring
ethtool -G eth0 tx N    # -G == --set-ring
```

### socket buffers
