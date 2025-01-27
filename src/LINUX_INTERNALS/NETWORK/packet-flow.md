# How packet flows via network stack (with tuning/debuging in mind)

### Disclaimer
this is my understanding, and I made a bunch of shortcuts in this notes
in purpouse. See some links for more detailed explanation:
- please start with **NETWORKING** chapters of Brendan Gregg books
- [https://tungdam.medium.com/linux-network-ring-buffers-cea7ead0b8e8](https://tungdam.medium.com/linux-network-ring-buffers-cea7ead0b8e8)
- [https://optiver.com/working-at-optiver/career-hub/searching-for-the-cause-of-dropped-packets-on-linux/](https://optiver.com/working-at-optiver/career-hub/searching-for-the-cause-of-dropped-packets-on-linux/)
- [https://blog.tsunanet.net/2011/03/out-of-socket-memory.html](https://blog.tsunanet.net/2011/03/out-of-socket-memory.html)
- [https://www.coverfire.com/articles/queueing-in-the-linux-network-stack/](https://www.coverfire.com/articles/queueing-in-the-linux-network-stack/)
- [https://blog.packagecloud.io/monitoring-tuning-linux-networking-stack-sending-data/](https://blog.packagecloud.io/monitoring-tuning-linux-networking-stack-sending-data/)
- [https://blog.packagecloud.io/monitoring-tuning-linux-networking-stack-receiving-data/](https://blog.packagecloud.io/monitoring-tuning-linux-networking-stack-receiving-data/)
- [https://blog.packagecloud.io/illustrated-guide-monitoring-tuning-linux-networking-stack-receiving-data/](https://blog.packagecloud.io/illustrated-guide-monitoring-tuning-linux-networking-stack-receiving-data/)

### ok, lesssgo

- First of: **SEND** and **RECEIVE** paths are different.
- Second of: I'm going to just write some text, to see some nice pictures
  please open links above

#### SEND path

#### RECEIVE path
- nic receives a packet
- it is being put in a "ring buffer", aka "driver queue"
- ring buffer does not contain actual data, but POINTERS to SKB data structures
  (SKB == socket kernel buffer, `struct sk_buff`)
- the process of receive, starts with HARD IRQ - handled by NIC, which in turn
  triggers SOFT IRQ, handled by kernel threads: `ksoftirqd` (one per CPU thread)

