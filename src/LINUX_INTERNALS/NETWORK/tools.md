---

### standard
- [ethtool](../../COMMANDS/ETHTOOL/index.md)
- [ip](../../COMMANDS/IP/index.md)
- [iperf](../../COMMANDS/IPERF/index.md)
- [netstat](../../COMMANDS/NETSTAT/index.md)
- [nicstat](../../COMMANDS/NICSTAT/index.md)
- [nstat](../../COMMANDS/NSTAT/index.md)
- [ss](../../COMMANDS/SS/index.md)

### bpf (bcc)
- [gethostlatency](../../COMMANDS/GETHOSTLATENCY/index.md)
- [solisten](../../COMMANDS/SOLISTEN/index.md) - pretty cool one, prints socket `listen(2)` calls with details
- [tcpaccept](../../COMMANDS/TCPACCEPT/index.md)
- [tcpconnect](../../COMMANDS/TCPCONNECT/index.md)
- [tcplife](../../COMMANDS/TCPLIFE/index.md)
- [tcpretrans](../../COMMANDS/TCPRETRANS/index.md)
- [tcpstates](../../COMMANDS/TCPSTATES/index.md) - prints TCP session state changes
- [tcpsynbl](../../COMMANDS/TCPSYNBL/index.md) - tracing SYN backlog size (and DROPs)
- [tcptop](../../COMMANDS/TCPTOP/index.md)
- [tcptracer](../../COMMANDS/TCPTRACER/index.md)  <-- that's the one you most likely are looking for

### bpftrace

note: most bpftrace tools got ported to bcc, so it's prefferable to execute bcc versions

for one liners see [bpftrace/network](../../PROGRAMMING/BPFTRACE/network.md)

for ready to use scripts also see [bpftrace/network](../../PROGRAMMING/BPFTRACE/network.md),
but here is the list:
- `sockstat.bt`
- `sofamily.bt`
- `soprotocol.bt`
- `soconnetct.bt`
- `soaccept.bt`
- `socketio.bt`
- `socketsize.bt`
- `sormem.bt`
- `soconnlat.bt`
- `so1stbyte.bt`
- `tcpwin.bt`
- `tcpnagle.bt`
- `udpconnect.bt`
- `netsize.bt`
- `nettxlat.bt`
