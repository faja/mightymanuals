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

# TCP send bytes as a histogram
bpftrace -e 'k:tcp_sendmsg { @send_bytes = hist(arg2); }'

# TCP receive bytes as a histogram
bpftrace -e 'kr:tcp_recvmsg /retval >=0/ { @recv_bytes = hist(retval); }'

# UDP send bytes as a histogram
bpftrace -e 'k:udp_sendmsg { @send_bytes = hist(arg2); }'

# UDP receive bytes as a histogram
bpftrace -e 'kr:udp_recvmsg /retval >=0/ { @recv_bytes = hist(retval); }'
```

### scripts

- xxx
- yyy
- zzz
