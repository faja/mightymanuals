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
- ring buffer does not contain actual data, but POINTERS to memory area where
  packet are being copied by nic via DMA (direct memory access)
- when data is saved in memory, nic sends **hardware interrupt** (HARD IRQ)
  which in turn triggers **softwarde interrupt** (SOFT IRQ), `NET_RX_SOFTIRQ` signal
  sent to kernel thread `ksoftirqd` (one per CPU thread)
- main function that pulls data from ring buffer is called `net_rx_action`,
  it allocates SKB data structures (SKB == socket kernel buffer, `struct sk_buff`)
  via `alloc_skb()`
- hence, if traffic is busy, you can see `ksoftirq` thread consuming a lot of
  CPU by `net_rx_action`, but of course it has a limited budget to run.
  There are 3 cases, when that fuction stops:
    - there is no more data to read from
    - it exceeded `budget` defined by `net.core.netdev_budget` – amount of packets
      that can be handled at most in a single run
    - it took too long to finish (`net.core.netdev_budget_usecs`)
    - (you can find the details on the above here `/proc/net/softnet_stat`)

#### linux network stack

![](./images/linux_network_stack.jpg)

#### linux tcp backlogs

![](./images/linux_network_backlogs.jpg)

