---

`tcplife` - a **BCC** tool that displays TCP connections

**BUT/NOTES**:

- only after a connection changes it's state to `TCP_CLOSE`
- for "show me all the connection that being made" please see [tcpconnect](../TCPCONNECT/index.md)
  or [tcptracer](../TCPTRACER/index.md)
- also please note, `tcplife` command must be started before a connection is established
  to print it after it finishes
- useful if we have a lot of short lived connection and we just wanna see which
  process is making that, and how long they last


```sh
tcplife -w -T    # wider output, show time
tcplife -4       # IPv4 only
tcplife -p 12345 # only trace process ID 12345
```
