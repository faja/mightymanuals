---

- [ring buffers (nic buffers)](#ring-buffers)
- [net_rx_action budget/limit](#net-rx-action)
- [socket buffers, tcp_rmem, tcp_wmem](#socket-buffers)
- [tcp memory, tcp_mem, sockstat](#tcp-memory)

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
# 1 line per cpu core
awk '{print $3}' /proc/net/softnet_stat
# The third value, sd->time_squeeze, is (as we saw) the number of times the
# net_rx_action loop terminated because the budget was consumed or the
# time limit was reached, but more work could have been.

cat /proc/sys/net/core/netdev_budget
# how many packets can be handled at most in a single run of `net_rx_action`
# default 300, experiment with 2x or 3x
echo 600 > /proc/sys/net/core/netdev_budget

cat /proc/sys/net/core/netdev_budget_usecs
# how long can single rune of `net_rx_action` take
```

### socket buffers
<span style="color:#ff4d94">**interesting note:**</span>
if packet is dropped due to socket buffer is full (bc app can not handle
the traffic/load), it doesn't appear as `dropped` in metrics (eg: netstat -s)
it's `packets pruned from receive queue because of socket buffer overrun`

### tcp memory

```sh
# get number of sockets in use, allocated sk_buff struct, and all the memory
cat /proc/net/sockstat
# eg output (cuttet):
#  TCP: inuse 35938 orphan 21564 tw 70529 alloc 35942 mem 1894
# the last value is in PAGES and it means how much memory is allocated to TCP

# get tcp memory "limits"
cat /proc/sys/net/ipv4/tcp_mem
# eg output:
#   3093984 4125312 6187968
# these are in PAGES (4096 bytes)(run `getconf PAGESIZE` to double check)
# and represent min, pressure, max
# for more details on that file see
# https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/Documentation/networking/ip-sysctl.rst
```
