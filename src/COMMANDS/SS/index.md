---

### usage

```sh
# top1
ss -ntap sport 22 # list all sockets related to port 22

# basics:
ss -n # do not resolve ip addresses and ports
ss -t # show ONLY TCP sockets
   -p # show process details
   -l # show ONLY sockets in LISTEN state
   -a # print TCP sockets in all STATES

# advanced:
ss -m # awesome stuff shows MEMORY usage for a socket, see below
   -i # TCP internal info
   -e # extended socket info

# examples:
ss -ntlp                    # show TCP sockets in LISTEN state
ss -ntpa sport 22           # show all ssh connections
ss -n state all sport = :22 # same as above

# advanced examples:
## display socket backlog (connections not yet accepted by a process)
ss -n state syn-recv sport = :22
## show connections but NOT to postgres(5432) and redis(6379)
ss -nta 'dport != :5432 and dport != :6379'
```

### socket memory information
```sh
ss -ntpm

# skmem:(r0,rb131072,t0,tb87040,f0,w0,o0,bl0,d0)
#  - r  -
#  - rb -
#  - t  -
#  - tb -
#  - f  -
#  - w  -
#  - o  -
#  - bl -
#  - d  -


#
```
to get socket memory usage:
```sh
#
```

### tcp internal info
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
