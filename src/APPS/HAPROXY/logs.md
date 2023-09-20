# understanding the log lines

## default TCP logs

example and most important fileds (I'm skipping the obvious ones),
for full info see [oficial docs](https://docs.haproxy.org/2.8/configuration.html#8.2.2)
```
haproxy[1]: 10.116.68.134:55108 [20/Sep/2023:09:14:29.513] tcp~ electrum/electrumx1 21/3/382751 4843 sD 7/5/4/2/0 0/0
                                        ^                    ^      ^         ^          ^        ^   ^
                                        |                    |      |         |          |        |   |
                                        |                    |      |         |          |  bytes sent by server
                when the connection was accepted             |      |         |          |            |
(hint, log entry time tells you when it was closed)     frontend    |      server        |            |
                                                                    |                  times         termination status
                                                                 backend      1st=wait in queue
                                                                              2nd=connection to server
                                                                              3rd=total time between accept and close
```

## default HTTP logs
TODO

## connection/termination state field
This is the filed containing **4** characters (or **2** for TCP), it looks like: `----`, `sC--`
[docs](http://docs.haproxy.org/2.8/configuration.html#8.5)

examples:

- `sC--` - CONNECTION to the server timed out
- `SD--` - (`S`) the TCP session was ABORTED by the server, (`D`) the session was in the DATA phase
- `sD--` - (`s`) server-side timeout while waiting for send or receive, (`D`) the session was in the DATA phase
- `CD--` - (`C`) the TCP session was ABORTED by the client, (`D`) the session was in the DATA phase
- `PR--` - (`P`) session closed "prematurely", due to DENY match, or connection limit, nothing was sent to the backend server

## connection timing filed
0/613/-1/-1/820
TR '/' Tw '/' Tc '/' Tr '/' Ta*

# trix
- how to disable logging completely for a frontend or a backend
```
frontend/backend ...
    no log
```
