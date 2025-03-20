---

`solisten` - a **BCC** tool that prints socket listen calls with details,
  pretty cool if you wanna trace and see which processes starting to listen
  on which port

eg:

```sh
# solisten -t
TIME(s)  PID     COMM             RET BACKLOG PROTO PORT  ADDR
20:56:19 1908    nc               0   1       TCPv4 44001 0.0.0.0
20:56:22 1909    nc               0   1       TCPv4 44173 0.0.0.0
20:56:38 1910    redis-server     0   511     TCPv4 6379  0.0.0.0
20:56:38 1910    redis-server     0   511     TCPv6 6379  ::
```

