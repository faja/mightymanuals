---

<span style="color:#ff4d94">**NOTE:**</span> see `NETWORK` section of both Brendan's
books for all examples

### one-liners

```sh
###############################################################################
# NOTE: kinda PITA with these 1liners is that `count()` prints the output
#       only when you CTRL+C
###############################################################################

# PRINT(live) socket accept(2)s by PID and process name
bpftrace -e 't:syscalls:sys_enter_accept* { printf("%d, %s\n", pid, comm); }'

# COUNT socket accept(2)s by PID and process name
bpftrace -e 't:syscalls:sys_enter_accept* { @[pid, comm] = count(); }'

# COUNT socket connect(2)s by PID and process name
bpftrace -e 't:syscalls:sys_enter_connect { @[pid, comm] = count(); }'

# COUNT socket connect(2)s by user stack trace
bpftrace -e 't:syscalls:sys_enter_connect { @[ustack, comm] = count(); }'

# COUNT sock_sendmsg per process
bpftrace -e 'kprobe:sock_sendmsg { @[comm] = count(); }'

# TCP send bytes as a histogram
bpftrace -e 'k:tcp_sendmsg { @send_bytes = hist(arg2); }'

# TCP receive bytes as a histogram
bpftrace -e 'kr:tcp_recvmsg /retval >=0/ { @recv_bytes = hist(retval); }'

# UDP send bytes as a histogram
bpftrace -e 'k:udp_sendmsg { @send_bytes = hist(arg2); }'

# UDP receive bytes as a histogram
bpftrace -e 'kr:udp_recvmsg /retval >=0/ { @recv_bytes = hist(retval); }'
```

### scripting

Simple scripting is relatively straight forward, nice example that is self explanatory

- `sockstat.bt`

```bt
#!/usr/bin/bpftrace

BEGIN
{
    printf("Tracing sock statistics. Output every 1 seconf.\n");
}

tracepoint:syscalls:sys_enter_accept*,
tracepoint:syscalls:sys_enter_connect,
tracepoint:syscalls:sys_enter_bind,
tracepoint:syscalls:sys_enter_socket,
kprobe:sock_recvmsg,
kprobe:sock_sendmsg
{
    @[probe] = count();
}

interval:s:1
{
    time();
    print(@);
    clear(@);
}
```

- `sordrop.bt`
```bt
#!/usr/bin/bpftrace

BEGIN
{
    printf("Tracing socket receive buffer full. Hit Ctrl-C to end.\n");
}

tracepoint:sock:sock_rcvqueue_full
{
    printf("%s rmem_alloc %d > rcvbuf %d, skb size %d\n", probe,
        args->rmem_alloc, args->sk_rcvbuf, args->truesize);
}

tracepoint:sock:sock_exceed_buf_limit
{
    printf("%s rmem_alloc %d, allocated %d\n", probe,
        args->rmem_alloc, args->allocated);
}
```

### ready to use scripts

- `sockstat.bt`
- `sofamily.bt`
- `soprotocol.bt`
- `soconnect.bt`
- `soaccept.bt`
- `socketio.bt`
- `socketsize.bt`
- `sormem.bt`
- `soconnlat.bt`
- `so1stbyte.bt`
- `udpconnect.bt`
- `netsize.bt`
- `nettxlat.bt`
- `skbdrop.bt`/`tcpdrop.bt`
- `skblife.bt`

(see BRENDAN's books for source code)

- **`sockstat.bt`** - prints socket statistics, socket events count each second,

    eg:
    ```sh
    # sockstat.bt
    Attaching 10 probes...
    Tracing sock statistics. Output every 1 second.
    01:11:41
    @[tracepoint:syscalls:sys_enter_bind]: 1
    @[tracepoint:syscalls:sys_enter_socket]: 67
    @[tracepoint:syscalls:sys_enter_connect]: 67
    @[tracepoint:syscalls:sys_enter_accept4]: 89
    @[kprobe:sock_sendmsg]: 5280
    @[kprobe:sock_recvmsg]: 10547

    01:11:42
    [...]
    ```

- **`sofamily.bt`** - summarizes `accept(2)` and `connect(2),` per process with address family

    eg:
    ```sh
    # sofamily.bt
    Attaching 7 probes...
    Tracing socket connect/accepts. Ctrl-C to end.
    ^C

    @accept[sshd, 2, AF_INET]: 2
    @accept[java, 2, AF_INET]: 420

    @connect[sshd, 2, AF_INET]: 2
    @connect[sshd, 10, AF_INET6]: 2
    @connect[(systemd), 1, AF_UNIX]: 12
    @connect[sshd, 1, AF_UNIX]: 34
    @connect[java, 2, AF_INET]: 215
    ```

- **`soprotocol.bt`** - summarizes `accept(2)` and `connect(2)`, per process with protocol name
    pretty similar to the previous one

    eg:
    ```sh
    # soprotocol.bt
    Attaching 4 probes...
    Tracing socket connect/accepts. Ctrl-C to end.
    ^C

    @accept[java, 6, IPPROTO_TCP, TCP]: 1171

    @connect[setuidgid, 0, IPPROTO, UNIX]: 2
    @connect[ldconfig, 0, IPPROTO, UNIX]: 2
    @connect[systemd-resolve, 17, IPPROTO_UDP, UDP]: 79
    @connect[java, 17, IPPROTO_UDP, UDP]: 80
    @connect[java, 6, IPPROTO_TCP, TCP]: 559
    ```

- **`soconnect.bt`** - prints socket connect requests, via syscall tracepoints:
    `sys_enter_connect` and `sys_exit_connect` - it's a bit nicer
    version of `tcpconnect`/`tcptracer` (but if you don't need all these details
    still prefered is `tcpconnect`/`tcptracer`). Fields printed:
    PID, PROCESS, ADDRESS, PORT, LATENCY, RESULT - the nice thing
    is it traces the exit syscall and we can get the RESULT

    eg:
    ```sh
    # soconnect.bt
    Attaching 4 probes...
    PID    PROCESS  FAM  ADDRESS       PORT  LAT(us)  RESULT
    11448  ssh      2    127.0.0.1     22    43       Success
    11449  ssh      2    10.168.188.1  22    45134    Success
    11451  curl     2    100.66.96.2   53    6        Success
    11451  curl     2    52.43.200.64  80    7        Success
    11451  curl     2    52.24.119.28  80    19       In progress
    ```

- **`soaccept.bt`** - prints socket accept requests, via syscall tracepoints:
    `sys_enter_accept` and `sys_exit_accept` - same as above (CONNECT)
    but for ACCEPT

    eg:
    ```sh
    # soaccept.bt
    Attaching 6 probes...
    PID   PROCESS  FAM  ADDRESS         PORT   RESULT
    4225  java     2    100.85.215.60   65062  Success
    4225  java     2    100.85.54.16    11742  Success
    4225  java     2    100.82.213.228  18500  Success
    4225  java     2    100.85.209.89   20150  Success
    4225  java     2    100.82.21.93    27278  Success
    ```

- **`socketio.bt`** - prints socket I/O counts - how many which process read or writen
    to/from a socket (process, pid, direction, protocol, port, count)

    eg:
    ```sh
    # socketio.bt
    Attaching 4 probes...
    ^C
    @io[sshd, 13348, write, TCP, 49076]: 1
    @io[redis-server, 2583, write, TCP, 41154]: 5
    @io[redis-server, 2583, read, TCP, 41154]: 5
    @io[java, 3929, read, TCP, 6001]: 1367
    @io[java, 3929, write, TCP, 8980]: 24979
    ```

- **`socketsize.bt`** - a histogram of total bytes socket IOs per process and direction

    eg:
    ```sh
    # socketio.bt
    Attaching 2 probes...
    ^C

    @read_bytes[sshd]:
    [32, 64)             1 [ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ ]

    @read_bytes[java]:
    [0]                431 [ @@@@@                                         ]
    [1]                  4 [                                               ]
    [2, 4)              10 [                                               ]
    ...
    [1K, 2K)          2972 [ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@              ]
    [2K, 4K)          1863 [ @@@@@@@@@@@@@@@                               ]
    [4K, 8K)          2501 [ @@@@@@@@@@@@@@@@@@@@@@@@@                     ]
    ...

    @write_bytes[sshd]:
    [32, 64)             1 [ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ ]

    @write_bytes[java]:
    [8, 16)             36 [                                               ]
    [16, 32)             6 [                                               ]
    [32, 64)          6131 [ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ ]
    ...
    [2K, 4K)          3607 [ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@              ]
    [4K, 8K)          2673 [ @@@@@@@@@@@@@@@@@@@@@@                        ]
    ...
    ```

- **`sormem.bt`** - prints histogram of how full receive socket buffer is compared
    to the configured limit, it prints two histograms: `@rmem_alloc`
    (what is currently in use) and `@rmem_limit` (what limitas are configured)
    it can be use, to determine if configured limits make sense

    eg:
    ```sh
    # sormem.bt
    Attaching 4 probes...
    Tracing socket receive buffer size. Hit Ctrl-C to end.
    ^C

    @rmem_alloc:
    [0]              72870 [ @@@@@@@@@@@@@@@@@@@@@@@                       ]
    [1]                  0 [                                               ]
    [2, 4)               0 [                                               ]
    [4, 8)               0 [                                               ]
    [8, 16)              0 [                                               ]
    ...
    [512, 1K)       113831 [ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ ]
    [1K, 2K)           113 [                                               ]
    [2K, 4K)           105 [                                               ]
    [4K, 8K)         99221 [ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@        ]
    [8K, 16K)        26726 [ @@@@@@@@                                      ]
    [16K, 32K)       58028 [ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@                 ]
    [32K, 64K)       31336 [ @@@@@@@@@@@@                                  ]
    [64K, 128K)       6692 [ @@@                                           ]
    [128K, 512K)         0 [                                               ]
    ...
    [1M, 2M)            45 [                                               ]
    [2M, 4M)            80 [                                               ]


    @rmem_limit:
    [64K, 128K)      14447 [ @                                             ]
    [128K, 256K)       262 [                                               ]
    [256K, 512K)         0 [                                               ]
    ...
    [4M, 8M)             0 [                                               ]
    [8M, 16M)       410158 [ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ ]
    [16M, 32M)           7 [                                               ]

    ```

- **`soconnlat.bt`** - shows socket connection latency as aa histogram (with user-level
    stack traces). Similar to `soconnect.bt` but helps you identify
    connections by code paths (source code that causes connections),
    works by tracing `connect(2)`, `select(2)`, `poll(2)`(family)

    eg:
    ```sh
    # soconnlat.bt
    Attaching 12 probes...
    Tracing IP connect() latency with ustacks. Ctrl-C to end.
    ^C

    @us[
        __GI___connect+108
        ...<cut - full stack trace>...
        __clone+63
    , FreeColClient:W]:
    [32, 64)             1 [ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ ]

    @us[
        __connect+71
    , java]:
    [128, 256)          69 [ @@@@@@@@@@@@@@@@@@@@@@@@@@                    ]
    [256, 512)          28 [ @@@@@@@@@                                     ]
    [512, 1K)          121 [ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    ]
    [1K, 2K)            53 [ @@@@@@@@@@@@@@@@@@@                           ]
    ```

- **`so1stbyte.bt`** - traces the time from issuing an IP socket connect(2) to the
    first read byte for that socket, works by instrumenting
    syscall tracepoints `connect(2)`, `read(2)`, `recv(2)`

    eg:
    ```sh
    # so1stbyte.bt
    Attaching 21 probes...
    Tracing IP socket first-read-byte latency. Ctrl-C to end.
    ^C

    @us[java]:
    [256, 512)           4 [                                               ]
    [512, 1K)            5 [ @                                             ]
    [1K, 2K)            34 [ @@@@@@                                        ]
    [2K, 4K)           212 [ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@      ]
    [4K, 8K)           260 [ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ ]
    ...
    [256K, 512K)         3 [                                               ]

- **`udpconnect.bt`** - traces new UDP connections

    eg:
    ```sh
    # udpconnect.bt
    Attaching 3 probes...
    TIME      PID   COMM             IP  RADDR                 RPORT
    20:58:38  6039  DNS Res~er #540  4   10.45.128.25          53
    20:58:38  2621  TaskSchedulerFo  4   10.45.128.25          53
    20:58:39  3876  Chrome_IOThread  6   2001:4860:4860::8888  53
    [...]
    ```

- **`netsize.bt`** - shows size of received and sent packets at the NIC
  (`@nic_{}_bytes`) and in the kernel network stack (`@{}_bytes`)

    eg:
    ```sh
    # netsize.bt
    Attaching 5 probes...

    @nic_recv_bytes:
    [32, 64)         16291 [ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ ]
    [64, 128)          668 [ @@                                            ]
    [128, 256)          19 [                                               ]
    [256, 512)          18 [                                               ]
    [512, 1K)           24 [                                               ]
    [1K, 2K)           157 [                                               ]

    @nic_send_bytes:
    [32, 64)           107 [                                               ]
    [64, 128)          356 [                                               ]
    [128, 256)         139 [                                               ]
    [256, 512)          31 [                                               ]
    [512, 1K)           15 [                                               ]
    [1K, 2K)         45850 [ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ ]

    @recv_bytes:
    [32, 64)         16291 [ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ ]
    [64, 128)          668 [ @@                                            ]
    [128, 256)          20 [                                               ]
    ...
    [8K, 16K)            3 [                                               ]
    [16K, 32K)           2 [                                               ]

    @send_bytes:
    [32, 64)           107 [ @@@                                           ]
    [64, 128)          356 [ @@@@@@@@@@@@@@                                ]
    [128, 256)         139 [ @@@@                                          ]
    ...
    [8K, 16K)          391 [ @@@@@@@@@@@@@@@@@@                            ]
    [16K, 32K)        1563 [ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ ]
    ```

- **`nettxlat.bt`** - time spent pushing the packet into the driver layer to enqueue
  it on a TX ring

    eg:
    ```sh
    # nettxlat.bt
    Attaching 4 probes...
    Tracing net device xmit queue latency. Hit Ctrl-C to end.
    ^C

    @us:
    [4, 8)          2230 [                                               ]
    [8, 16)       150679 [ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@                 ]
    [16, 32)      275351 [ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ ]
    [32, 64)       59898 [ @@@@@@@@                                      ]
    [64, 128)      27597 [ @@@@                                          ]
    [128, 256)       276 [                                               ]
    [256, 512)         9 [                                               ]
    [512, 1K)          3 [                                               ]
    ```

- **`skbdrop.bt`** / **`tcpdrop.bt`** - `skbdrop` traces unusual skb drop events,
  but it prints stack traces and counts per stack trace. I believe `tcpdrop`
  just prints the drop events (also I think there should be a `tcpdrop` BCC version)

    eg:
    ```sh
    # skbdrop.bt
    Attaching 3 probes...
    Tracing  unusual skb drop stacks. Hit Ctrl-C to end.
    ^C

    [...]

    @[
        kfree_skb+118
        <cut..stack trace..>
        SYSC_recvfrom+228
    ]: 50

    @[
        kfree_skb+118
        <cut..stack trace..>
        tcp_rcv_state_process+1501
    ]: 142

    @[
        kfree_skb+118
        <cut..stack trace..>
        __netif_receive_skb+24
    ]: 276
    ```

- **`skblife.bt`** - pretty cool - it measures and print as a histogram - how long `sk_buff`
  structs live while they are being passed thorugh the network kernel stack

    eg:
    ```sh
    # skblife.bt
    Attaching 6 probes...
    ^C

    @skb_residency_nsecs:
    [1K, 2K)       163 [                                               ]
    [2K, 4K)       792 [ @@@                                           ]
    [4K, 8K)      2591 [ @@@@@@@@@@@@@@                                ]
    [8K, 16K)     3022 [ @@@@@@@@@@@@@@@@@                             ]
    [16K, 32K)   12695 [ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ ]
    ...
    [32M, 64M)      12 [                                               ]
    [64M, 128M)      1 [                                               ]
    [128M, 256M)     1 [                                               ]
    ```

- other scripts that can be found in the books:
  `tcpwin.bt`, `tcpnagle.bt`, `ippecn`, `superping`, `qdisc-fq`, `qdisc-*`
