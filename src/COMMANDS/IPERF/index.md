---

`iperf` - tool for testing TCP and UDP throughput

```sh
yum install -y iperf3
apt-get -y install iperf3
```

```sh

	+------------------+                      +----------------+
	| Linux server A    +---------------------+ Linux server B +
	+------------------+                      +----------------+
	IP:192.168.59.100                         IP:192.168.59.101
	iperf server                              iperf client


server: iperf -s -B 192.168.59.100 -p 5201 -l 128k -1
client: iperf -c    192.168.59.100 -p 5201 -l 128k -P 2 -i 1 -t 60

  -s         - run in server mode
  -1         - in server mode, run ONE test, then exit
  -B ${IP}   - in server mode, bind to ${IP}
  -c ${IP}   - run in client mode, connect to ${IP}
  -p ${PORT} - port
  -l 128k    - use 128 Kbyte socket buffer
  -P 2       - run in parallel mode with two client threads
  -i 1       - show stats every 1 second
  -t 60      - total duration of the test: 60 seconds
```
