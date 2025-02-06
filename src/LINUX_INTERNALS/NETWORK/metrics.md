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

- SYN backlog lenght

- LISTEN backlog lenght

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


## network related softirqs
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
