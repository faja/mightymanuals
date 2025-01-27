---

```sh
# show statistics, check rx,tx ring buffer drops
ethtool -S eth0 | grep drop

# check current setting
ethtool -g eth0         # -g == --show-ring

# set new queue length for rx,tx
ethtool -G eth0 rx N    # -G == --set-ring
ethtool -G eth0 tx N    # -G == --set-ring

# check offload settings
ethtool -k eth0
```
