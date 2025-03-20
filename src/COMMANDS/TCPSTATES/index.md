---

`tcpstates` - **BPF** based tool, prints TCP session state change, with
  IP address and port details, and duration in each state

eg:

```sh
# tcpstates
SKADDR           PID     COMM       LADDR           LPORT RADDR           RPORT OLDSTATE    -> NEWSTATE    MS
ffff9db3464a1200 0       swapper/0  0.0.0.0         22    0.0.0.0         0     LISTEN      -> SYN_RECV    0.000
ffff9db3464a1200 0       swapper/0  10.0.2.15       22    10.0.2.2        56402 SYN_RECV    -> ESTABLISHED 0.021
ffff9db3464a7500 1877    nc         0.0.0.0         0     0.0.0.0         0     CLOSE       -> LISTEN      0.000
ffff9db3464a7500 1877    nc         0.0.0.0         34871 0.0.0.0         0     LISTEN      -> CLOSE       44285.289
ffff9db3464a7500 1908    nc         0.0.0.0         0     0.0.0.0         0     CLOSE       -> LISTEN      0.000
ffff9db3464a7500 1908    nc         0.0.0.0         44001 0.0.0.0         0     LISTEN      -> CLOSE       2786.727
ffff9db3464a7500 1909    nc         0.0.0.0         0     0.0.0.0         0     CLOSE       -> LISTEN      0.000
ffff9db3464a7500 1909    nc         0.0.0.0         44173 0.0.0.0         0     LISTEN      -> CLOSE       778.175
ffff9db3464a7500 1910    redis-serv 0.0.0.0         6379  0.0.0.0         0     CLOSE       -> LISTEN      0.000
ffff9db3753e7200 1910    redis-serv ::              6379  ::              0     CLOSE       -> LISTEN      0.000
ffff9db3464a7500 1910    redis-serv 0.0.0.0         6379  0.0.0.0         0     LISTEN      -> CLOSE       3316.835
ffff9db3753e7200 1910    redis-serv ::              6379  ::              0     LISTEN      -> CLOSE       3318.650
```
