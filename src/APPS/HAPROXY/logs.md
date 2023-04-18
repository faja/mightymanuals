# understanding the log lines


## connection/termination state field
This is the filed containing **4** characters, it looks like: `----`, `sC--`
[docs](http://docs.haproxy.org/2.6/configuration.html#8.5)

examples:

- `sC--` - CONNECTION to the server timed out
- `PR--` - session closed "prematurely", due to DENY match, or connection limit, nothing was sent to the backend server
- `SD--` - the TCP session was aborted by the server, the session was in the DATA phase
- `CD--` - the TCP session was aborted by the client, the session was in the DATA phase

## connection timing filed
0/613/-1/-1/820
TR '/' Tw '/' Tc '/' Tr '/' Ta*
