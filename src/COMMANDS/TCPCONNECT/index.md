---

`tcpconnect` - **BPF** based tool, that shows **"active"** TCP connections - the one
               caused by `connect()` syscall -  aka **outgoing** connections

(see also: [tcptracer](../TCPTRACER/index.md) and [tcpaccept](../TCPACCEPT/index.md))

```sh
tcpconnect            # default output, pretty good
tcpconnect -U -t      # include UID, include timestamp
tcpconnect -p ${PID}  # only trace PID
tcpconnect -u ${UID}  # only trace UID
tcpconnect -P 80,81   # only trace port 80 and 81
```
