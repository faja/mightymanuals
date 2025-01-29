---

- [ring buffers (nic buffers)](#ring-buffers)
- [net_rx_action budget/limit](#net-rx-action)
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

### net_rx_action

```sh
cat /proc/net/softnet_stat
awk '{print $3}' /proc/net/softnet_stat
# The third value, sd->time_squeeze, is (as we saw) the number of times the
# net_rx_action loop terminated because the budget was consumed or the
# time limit was reached, but more work could have been.

cat /proc/sys/net/core/netdev_budget
# default 300, experiment with 2x or 3x
echo 600 > /proc/sys/net/core/netdev_budget
```

### socket buffers


