---

`ethtool` is a realy powerfull tool that talks to kernel device drivers (via ioctl syscall).


```sh
apt-get -y install ethtool
```

```sh
### NOTE! changing any setting most likely brings interface down and up!
###       causing interruption of all the connections!!!

# show statistics, check rx,tx ring buffer drops
ethtool -S eth0 | grep drop

## NUMBER OF QUEUES
# check current setting
ethtool -l eth0        # note, not all drivers support -l
                       # if it doesn't, it's a single queue
# set new number of queues
ethtool -L eth0 rx 8
ethtool -L eth0 tx 8

## QUEUE LENGHT
# check current setting
ethtool -g eth0         # -g == --show-ring
# set new queue length for rx,tx
ethtool -G eth0 rx N    # -G == --set-ring
ethtool -G eth0 tx N    # -G == --set-ring

# check various settings, eg offload (TFO, UFO, GSO)
ethtool -k eth0
# set various setting
ethtool -K eth0 <setting_option> <on/off>
```
