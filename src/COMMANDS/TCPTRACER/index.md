---

`tcptracer` - awesome **BPF** based tool that shows pasive and active TCP connections,
              also when it is closed, what the tool is missing is filter by PORT:(

(see also: [tcpconnect](../TCPCONNECT/index.md), [tcpaccept](../TCPACCEPT/index.md))


```sh
## `T` (type) column:
# A - accepted, accept()   - passive tcp connection
# C - connected, connect() - active tcp connection
# X - closed connection

tcptracer           # default output, pretty good
tcptracer -U  -t    # include UID, include timestamp
tcptracer -p ${PID} # only trace PID
tcptracer -u ${UID} # only trace UID
```
