---

```sh
# basics:
ss -n # do not resolve ip addresses and ports
ss -t # show ONLY TCP sockets
   -p # show process details
   -l # show ONLY sockets in LISTEN state

# eg:
ss -ntlp              # show TCP sockets in LISTEN state
ss -ntp  | grep ":22" # show all ssh connections

# advanced:
ss -m # awesome stuff shows MEMORY usage for a socket, see below
   -i # TCP internal info
   -e # extended socket info
```

### socket memory information
```sh
ss -ntpm

#
```

### TCP internal info
```sh
ss -ntpi

# you can get pretty detailed info here, like:
#  - rto - tcp retransmission timeout
#  - rtt - average round-trip time and mean deviation (ms)
#  - mss - maximum segment size
#  - bytes_sent     - bytes transmistted
#  - bytes_acked    - bytes transmistted and got acked
#  - bytes_received - bytes received
```
<span style="color:#ff4d94">**NOTE:**</span> `-i` is awesome, but it is missing
time when the connection got established, a workaround is to: get **pid** and **fd**,
and exec: `stat /proc/${}/fd/${}` and look at `Change` time


### all sockets summary
```sh
ss -s
# equivalent of cat /proc/net/sockstat
```
