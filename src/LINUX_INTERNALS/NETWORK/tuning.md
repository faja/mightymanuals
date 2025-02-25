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

<span style="color:#ff4d94">**important NOTES:**</span>
- please keep in mind, TCP/SOCKETS memory is BARELY an issue, usually, limits
  are good, without even tuning that
- default limits are set dynamically based on available memory on the machine
  and as an example, on 16G ec2, 'MIN TCP LIMIT', below which
  kernel even doesn't bother is **~700MiB**, which is **crazy high!**
- you probably won't see any issues on the memory graphs for TCP,
  bc, memory issues are super short, due to quick connection/data burts
  because of that, you probably need to notice something is wrong, based on
  other counters (eg overflows) then use 1s (or even shorter) interval tools
  to meassure memory issues
- if packet is dropped due to socket buffer is full (bc app can not handle
  the traffic/load), it doesn't appear as `dropped` in metrics (eg: netstat -s)
  it's `packets pruned from receive queue because of socket buffer overrun`
- SOCKET buffer size is automatically adjusted based on usage, kernel does the
  job pretty well, however if you call `setsockopt()` with `SO_RCVBUF` or `SO_SNDBUF`
  autoadjustment is disabled

with that being said, lets first have a look on memory usage and tcp/udp limits

```sh
# TLDR;
#   TCP memory pressure: compare these two:
#     - `grep TCP /proc/net/sockstat`     # current usaage
#     - `cat /proc/sys/net/ipv4/tcp_mem`  # pressure limit

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
#
# handy dandy awk to print 'min' in MiB:
#   awk -v PAGESIZE=$(getconf PAGESIZE) '{print ($1*PAGESIZE)/(1024*1024) " MiB"}' /proc/sys/net/ipv4/tcp_mem

# get udp memory "limits"
cat /proc/sys/net/ipv4/udp_mem
# similar to `tcp` one
```

can you spot anything even close the the limits? probably not, but anyway:

TUNING:


```sh
# NOTE: defaults here are from aws linux 2 - eks edition 2025 - 16G memory

# tcp and udp system limits
net.ipv4.tcp_mem = ... ... ...
net.ipv4.udp_mem = ... ... ...
# defaults:
#   net.ipv4.tcp_mem = 186900       249202  373800  # min ~ 700MiB
#   net.ipv4.udp_mem = 373803       498405  747606  # min ~ 1.4GiB
# please REMEMBER these are in PAGES!
# see above for explanation, if really needed, just double the defaults
#  min: below this number of pages TCP is not bothered about its memory appetite.
#  pressure: when amount of memory allocated by TCP exceeds this number
#            of pages, TCP moderates its memory consumption and enters memory
#	         pressure mode, which is exited when memory consumption falls
#            under "min".
#  max: number of pages allowed for queueing by all TCP sockets.


# SOCKET BUFFER size (IN BYTES) - default and max
# (note, default for TCP is overwriten by `tcp_Xmem` seetings)
# these are per single SOCKET
net.core.rmem_default = ...
net.core.rmem_max = 16777216
net.core.wmem_default = ...
net.core.wmem_max = 16777216
# defaults:
#  net.core.rmem_default = 212992  # 208KiB
#  net.core.rmem_max     = 212992
#  net.core.wmem_default = 212992
#  net.core.wmem_max     = 212992


# TCP specific socket buffers sizes (for receive and send) - IN BYTES
net.ipv4.tcp_rmem = 4096 12582912 16777216
net.ipv4.tcp_wmem = 4096 12582912 16777216
# defaults:
#  net.ipv4.tcp_rmem = 4096        131072  6291456  # 4KiB 128KiB 6MiB
#  net.ipv4.tcp_wmem = 4096        20480   4194304  # 4KiB 20KiB  4MiB
# three values represent:
#  - min - minimum socket buffer size GUARANTEED
#  - default - default socket buffer size (this overrides `Xmem_default` setting)
#  - max - max buffer size (this overrides `Xmem_max` setting - but only if
#          `SO_RCVBUF` or `SO_SNDBUF` is NOT used!, usage of `SO_RCVBUF` or `SO_SNDBUF`
#          via `setsockopt()` is still limited by `Xmem_max`)
#          - this is confusing hence, it's good to set these two (max) the same
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
# note: this is not the actual lenght, the value is the max what we can get
# the actual value is calculated in some magic way
# tldr; set these two to the same value
# please also note that application calling listen() can specify the backlog lenght
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

# tcp_slow_start_after_idle, default: 1
# if enabled, there is a slow start after TCP idle period
# disabling that is generally recommended for latency performance
net.ipv4.tcp_slow_start_after_idle = 0

# tcp_syn_retries, default: 6
# number of initial SYN packet retransmits during the ACTIVE connection attempt
# don't know why default is 6, but netflix got it lowered to 2
net.ipv4.tcp_syn_retries = 2
# tcp_synack_retries, default: 5
# same but for PASSIVE connections
net.ipv4.tcp_synack_retries = 2

# ip_local_port_range, default: 32768    60999
# local port range for outgoing connections, can/should be bumped,
# but please remember this only affects OUTGOING (active) connections
# not incomming
net.ipv4.ip_local_port_range = 10240 65535

# tcp_abort_on_overflow, default: 0
# it configures behaviour if listen queue is full
# 0 - means DROP
# 1 - means send RST packet to the client
# i think I prefer 0, it is safer, and also client can retransmit SYN, and recover
# BUT! if your application is too slow to accept connections, you should REALLY
# do something about it, rather than playing with that tcp option
net.ipv4.tcp_abort_on_overflow = 0

###############################################################################
# conntrack
#
# nf_conntrack_buckets, default: 65536
# how many conntrack buckets to configure
# just a quick one:
# there is 1 conntrack hashtable -> with N keys (aka buckets)
# each bucket is actually a linked list, witn N nodes in it
# each node is a single conntrack entry
# (google for `conntrack hassh table` and see images)
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
```
