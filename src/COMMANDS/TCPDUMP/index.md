---

#### options/flags
```sh
-D              # show available interfaces
-i interface    # run agains selected interface only

-n              # do not resolve host names
-nn             # do not resolve port names

-ttt            # show time between packets
-ttttt          # show time since FIRST captured packet

-w filename     # save to a file
-r filename     # read from a file, previously saved, common usaage on that:
                # tcpdump -nr /tmp/out.tcpdump

-s number       # limit how many first bytes are captured
                # default: 96, 0 means no limit

-e              # show ETHERNET headers (mac addresses)
-X              # show packet content HEX + ASCII
-S              # show real seq numbers

-c number       # capture X number of packets and exit

-v,-vv,-vvv     # show more details
-q              # show less details
```

#### basic usage/examples
```sh
# protocols
tcpdump -nn icmp
tcpdump -nn udp
tcpdump -nn tcp
tcpdump -nn ip
tcpdump -nn arp

# filter by host, port
tpcdump -nn host 192.168.1.1
tcpdump -nn port 80
tcpdump -nn icmp and host 192.168.1.1        # proto and host
tcpdump -nn not port 22                      # NOT
tcpdump -nn 'host 192.168.1.1 and (port 68 or port 67)'
tcpdump -nn ... ether host XX:XX:XX:XX:XX    # filter by MAC

# filter by size
tcpdump -nn less 512  # `less`, `greater`
```

#### advanced: filter by TCP FLAG
```sh
tcpdump 'tcp[tcpflags] == tcp-syn'         # only SYN flag is set, nothig else
tcpdump 'tcp[tcpflags] & (tcp-syn) != 0'   # SYN is set,
                                           # but also can be any other flag
tcpdump 'tcp[tcpflags] == tcp-syn|tcp-ack' # only SYN+ACK
```
