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


- active/passive connections/s

- tcp states number of connections in particular state

- tcp errors (retransmits, out of order, etc..)


- socket stats (number of sockets)

- tcp memory usage (system)

- socket memory usage per socket

- SYN backlog lenght

- LISTEN backlog lenght

- syn received during a tcp time_wait
