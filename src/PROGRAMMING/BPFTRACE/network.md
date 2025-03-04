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

`sockstat.bt`

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

- sordrop.bt
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

(see BRENDAN's books for source code)

- `sockstat.bt` - prints socket statistics, socket events count each second
- `sofamily.bt` - summarizes accept(2) and connect(2), per process with address family
- `soprotocol.bt` - summarizes accept(2) and connect(2), per process with protocol name
                    pretty similar to the previous one
- `soconnetct.bt` - prints socket connect requests, via syscall tracepoints:
                    `sys_enter_connect` and `sys_exit_connect` - it's a bit nicer
                    version of `tcpconnect`/`tcptracer` (but if you don't need all these details
                    still prefered is `tcpconnect`/`tcptracer`). Fields printed:
                    PID, PROCESS, ADDRESS, PORT, LATENCY, RESULT - the nice thing
                    is it traces the exit syscall and we can get the RESULT
- `soaccept.bt` - prints socket accept requests, via syscall tracepoints:
                  `sys_enter_accept` and `sys_exit_accept` - same as above (CONNECT)
                  but for ACCEPT
- `socketio.bt` - prints socket I/O counts - how many which process read or writen
                  to/from a socket
- `socketsize.bt` - a histogram of total bytes socket IOs per process and direction
- `sormem.bt` - prints histogram of how full receive socket buffer is compared
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
