---

# Metrics in practice

- rx,tx bytes per second
- rx,tx packets per second
- packet drops, errors


    ```sh
    ethtool -S <interface>
    # or
    ip -s link
    ```

    or using `sysfs`
    eg:
    ```
    /sys/class/net/eno1/statistics/rx_bytes
    ```
    in general the path is:
    ```
    /sys/class/net/<INTERFACE_NAME>/statistics/<STAT_NAME>
    ```

    note: sysfs are slightly higer level than direct NIC level stats
    provided by `ethtool`

    even higher level is to read `/proc/net/dev`
    which provides 1line per interface stats

- ip packets tx,rx

    ```sh
    cat /proc/net/snmp
    cat /proc/net/netstat
    ```

- udp

    ```sh
    grep Udp /proc/net/snmp
    cat /proc/net/udp
    ```
- tcp

    ```sh
    grep Tcp /proc/net/snmp
    cat /proc/net/tcp
    ```

- active/passive connections/s

- tcp states number of connections in particular state

- tcp errors (retransmits, out of order, etc..)


- socket stats (number of sockets)

- tcp memory usage (system)


- socket memory usage per socket

# SYN and LISTEN queues

- check the overflow
```sh
nstat -az TcpExtListenOverflows TcpExtListenDrop
# these both refers to LISTEN queue being full,
# however the Drops is a bit more comples, as not always SYN is dropped
# when the LISTEN queue is full

# also check
netstat -s |  grep -i -e "listen" -e "pruned"
# these should give similar metrics

# NOTE! this is LISTEN queue related
# NOTE! there is no easy way of checking SYN queue overflows as far as I know :sadpanda:
```
NOTE! these are global counters, to actually see which app is dropping due to
full queue, you might need `bpf` as `ss` with 1 sec interval might be
hiding stuff

- get current SYN and ACCPET queues usage:
```sh
# get SYN queue lenght for port 80
ss -n state syn-recv sport :80 | wc -l
# get ACCEPT/LISTEN queue lenght for port 80
ss -nl sport :80 # look at Recv-Q
```

- syn cookies
```sh
# check the syn cookies - both sent with (SYN+ACK) and received with (ACK)
nstat -az TcpExtTCPReqQFullDoCookies TcpExtSyncookiesSent TcpExtSyncookiesRecv TcpExtSyncookiesFailed
# these might indicate SYN FLOODs or SYN queue getting full
```

# other stuff

- syn received during a tcp time_wait

## /proc/net/softnet_stat
```sh
$ cat /proc/net/softnet_stat
6dcad223 00000000 00000001 00000000 00000000 00000000 00000000 00000000 00000000 00000000
6f0e1565 00000000 00000002 00000000 00000000 00000000 00000000 00000000 00000000 00000000
660774ec 00000000 00000003 00000000 00000000 00000000 00000000 00000000 00000000 00000000
61c99331 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
6794b1b3 00000000 00000005 00000000 00000000 00000000 00000000 00000000 00000000 00000000
6488cb92 00000000 00000001 00000000 00000000 00000000 00000000 00000000 00000000 00000000
```

- each line correspond to a CPU
- tldr columns;
    - 1st: processed
    - 2nd: dropped - number of network frames dropped because there was no room
      on the processing queue
    - 3rd: time_squeeze - number of times the net_rx_action terminated, but
      there was still work to do, IMPORTANT!
- ...


## network related IRQs
```sh
# soft
grep -e CPU -e NET_ /proc/softirqs

# hard
grep -e CPU -e ${interface_name} /proc/interrupts
```

this is basicaly how often and on which CPU SOFT IRQs are being handled

note, that softirqs are triggered by hardirq, which in turn can be monitored
via `/proc/interrupts` - however, when it comes to network, some
drivers disable hardware interrupts if the packets are actively flowing

see also: `mpstat -I ALL` - print interrupt statistics

# /proc and /sys
- `/proc/net/dev` - quick and nice overview, `tx/rx`: `packets`, `errors`, `drops`,
    per interface
- `/proc/net/snmp` - awesome stuff, `Ip`, `Icmp`, `Tcp`, `Udp` detailed metrics,
    prett much the same stuff you get from `netstat -s`
- `/proc/net/netstat` - a lot of `Ip` and `Tcp` extended stats, (eg for TCP,
    there is more than 100 metrics)

- `/proc/net/tcp` - TCP sockets details, 1 line per socket: address, buffers, state, etc...
- `/proc/net/udd` - UDP sockets details, 1 line per socket: address, buffers, etc...

- `/proc/interrupts` and `/proc/softirqs` - network related HARD an SOFT IRQs

- `/sys/class/net/<INTERFACE_NAME>/statistics/<STAT_NAME>` - device stats, eg:
    ```sh
    cat /sys/class/net/eth0/statistics/{r,t}x_packets
    cat /sys/class/net/eth0/statistics/{r,t}x_dropped
    ```

- use awk to get something quickly with per second interval etc...
    ```sh
    awk -W interactive '{val=$1-val_p;val_p=$1;print "packets total:",val_p,", p/s:",val}' \
      <(while true; do cat /sys/class/net/eth0/statistics/rx_bytes ; sleep 1;done)
    #
    awk '/^TcpExt/ && NR==1 {gsub(" ","\n");print}' /proc/net/netstat | awk '{print NR, " : ", $0}'
    ```
