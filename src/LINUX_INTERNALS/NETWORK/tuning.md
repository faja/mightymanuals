---

- [ring buffers (nic buffers)](#ring-buffers)
- [multiqueue (RSS)](#multiqueue)
- [net_rx_action budget/limit](#net_rx_action)
- [tcp memory and socket buffers](#tcp-memory-settings-and-socket-buffers)
- [other sysctl tunnable](#other-sysctl-tunnable)

---

<span style="color:#ff4d94">
The networking stack is complex and there is no one size fits all solution.
</span>

---

# ring buffers

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

### also worth checking the offload settings, GRO, etc..
ethtool -k eth0 | grep offload
```
also see [commands/ethtool](../../COMMANDS/ETHTOOL/index.md) for more details


# multiqueue
If NIC supports RSS / multiqueue. It's worth to enable processing IRQs by multiple
CPUs. NOTE: it is usually enabled by default if nic support multiqueue:)

[official documentation](https://docs.kernel.org/networking/scaling.html)

TLDR;
- install and start `irqbalance` daemon
- enable RSS (Receive Side Scaling) to distrubute packet across different CPUs

NOTEs:
- RSS is usually enabled by default if NIC supports multiquueue
- limit number of queues to one per physical CPU core (not hyper threades!)

How to check if RSS is enabled:
```sh
ethtool -l ${interface_name}
grep -e CPU -e ${interface_name} /proc/interrupts
grep -e CPU -e NET_ /proc/softirqs
```

---

NOTE: RPS - Receive Packet Steering - it is a  "software" implementation of RSS,
usually it is disabled, especially if NIC supports multiqueue.

To check if RPS is enabled, cat `rps_cpus` of any qeueue of the network interface,
`0` means DISABLED, eg:
```
cat /sys/class/net/eth0/queues/rx-0/rps_cpus
```
another way of checking is by `cat /proc/net/softnet_stat` one of the last fileds
is `sd->received_rps` if it's all `0000...` that means there is no RPS.

For details on `softnet_stat` fields see kernel source code `net/core/net-procfs.c`
([eg](https://github.com/torvalds/linux/blob/v6.0/net/core/net-procfs.c#L171-L177))

# net_rx_action

```sh
cat /proc/net/softnet_stat
# 1 line per cpu core
awk '{print $3}' /proc/net/softnet_stat
# The third value, sd->time_squeeze, is (as we saw) the number of times the
# net_rx_action loop terminated because the budget was consumed or the
# time limit was reached, but more work could have been done

cat /proc/sys/net/core/netdev_budget
# how many packets can be handled at most in a single run of `net_rx_action`
# default 300, experiment with 2x or 3x
echo 600 > /proc/sys/net/core/netdev_budget

cat /proc/sys/net/core/netdev_budget_usecs
# how long can single rune of `net_rx_action` take
```

# tcp memory settings and socket buffers
<span style="color:#ff4d94">**interesting note:**</span>
if packet is dropped due to socket buffer is full (bc app can not handle
the traffic/load), it doesn't appear as `dropped` in metrics (eg: netstat -s)
it's `packets pruned from receive queue because of socket buffer overrun`

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

# other sysctl tunnable

<span style="color:#ff4d94">**NOTE:**</span> always check the defaults first
and rationale if it make sense changing any of these,

(defaults here are from aws linux 2 - eks edition 2025)

```sh
###############################################################################
# ip packets forwarding
#
# ip_forward, default: 1 - I think, 1 is the default on most distros, so just double check
net.ipv4.ip_forward = 1

###############################################################################
# tcp backlog
#
# tcp_max_syn_backlog, default: 1024
# "syn backlog" - backlog queue for half-open connections
net.ipv4.tcp_max_syn_backlog = 8192
# somaxconn, default: 4096
# "listen backlog" - per process backlog for passing connections to accept()
net.core.somaxconn = 8192

###############################################################################
# device backlog (valid only if RPS is enabled - which by default is NOT!)
#
# netdev_max_backlog, default: 1000
# per CPU queue, the name is a bit missleading, it is NOT the ring buffer aka driver queue
# and it is used only if RPS is used, hence this setting only makes sense to TUNE
# if we have RPS enabled, to check if RPS is enabled, cat `rps_cpus` of any qeueue
# of the network interface, `0` means DISABLED
#   cat /sys/class/net/eth0/queues/rx-0/rps_cpus
# another way of checking is by `cat /proc/net/softnet_stat`
# one of the last fileds is `sd->received_rps` if it's all 0000
# that means there is no RPS
#
# with all of that being said
#
# save to set it to 3000, and bump it further after monitoring `softnet_stat`
# and noticing some drops
net.core.netdev_max_backlog = 3000

###############################################################################
# misc
#
# tcp_tw_reuse, default: 2
# allows TIME_WAIT session to be reused when it appeears safe to do so
# it's related to avoiding socket ip:port pair collisions
# please also note there is even less safe/more aggressive option: tcp_tw_recycle
# (not recommended to touch tho)
net.ipv4.tcp_tw_reuse = 1


###############################################################################
# conntrack
#
# nf_conntrack_buckets, default: 65536
# how many conntrack buckets to configure
# just a quick one:
# there is 1 conntrack hashtable -> with N keys (aka buckets)
# each bucket is actually a linked list, witn N nodes in it
# each node is a single conntrack entry
net.netfilter.nf_conntrack_buckets = 655360
# nf_conntrack_max, default: 131072 # 2*buckets
# the maximum number of total conntrack entries
#   wc -l /proc/net/nf_conntrack
# it should be buckets *2 or *4 or *8
net.netfilter.nf_conntrack_max = 2621440 # 4*655360


###############################################################################
# BELOW ARE HIGHLY OPTIONAL,
# ONLY IF YOU REALLY REALLY WANNA TUNE BC OF SOME PERFORMANCE PROBLEMS
###############################################################################


###############################################################################
# queueing disciplines
#
# default_qdisc, default: pfifo_fast (debian default: fq_codel)
# change queueing discipline (qdisc)
# apparenlty fq_codel provides good performance in most cases
net.core.default_qdisc = fq_codel

###############################################################################
# congestion control
#
# tcp_congestion_control, default: cubic
# change congestion-control algorithm (linux supports pluggable congestion-control
# algorithms), to check currently available:
#   sysctl -a net.ipv4.tcp_available_congestion_control
# `BBR` is just example, but apparently is a good one, from GOOGLE
net.ipv4.tcp_congestion_control = bbr



###############################################################################
## TODO ## TODO ## TODO ## TODO ## TODO ## TODO ## TODO ## TODO ## TODO ##
net.core.rmem_max = 16777216                        # TODO read and understand
net.core.rmem_default = ...                        # TODO read and understand
net.core.wmem_max = 16777216                        # TODO read and understand
net.core.wmem_default = ...                        # TODO read and understand
net.ipv4.tcp_mem = ... ... ...             # TODO read and understand
net.ipv4.udp_mem = ... ... ...             # TODO read and understand
net.ipv4.tcp_rmem = 4096 12582912 16777216 # TODO read and understand
net.ipv4.tcp_wmem = 4096 12582912 16777216 # TODO read and understand
net.ipv4.tcp_rmem = 4096 12582912 16777216 # TODO read and understand

net.ipv4.ip_local_port_range = 10240 65535 # TODO read and understand
net.ipv4.tcp_abort_on_overflow = 1         # TODO read and understand , I think I prefer 0

net.ipv4.tcp_slow_start_after_idle = 0 # TODO read and understand
net.ipv4.tcp_syn_retries = 2           # TODO read and understand
net.ipv4.tcp_synack_retries = 2        # TODO read and understand
```
