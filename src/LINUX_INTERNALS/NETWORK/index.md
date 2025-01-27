---

links to read:
- [https://blog.packagecloud.io/monitoring-tuning-linux-networking-stack-receiving-data](https://blog.packagecloud.io/monitoring-tuning-linux-networking-stack-receiving-data)
- [https://tungdam.medium.com/linux-network-ring-buffers-cea7ead0b8e8](https://tungdam.medium.com/linux-network-ring-buffers-cea7ead0b8e8)
- [https://optiver.com/working-at-optiver/career-hub/searching-for-the-cause-of-dropped-packets-on-linux/](https://optiver.com/working-at-optiver/career-hub/searching-for-the-cause-of-dropped-packets-on-linux/)
- [https://blog.tsunanet.net/2011/03/out-of-socket-memory.html](https://blog.tsunanet.net/2011/03/out-of-socket-memory.html)
- [https://www.coverfire.com/articles/queueing-in-the-linux-network-stack/](https://www.coverfire.com/articles/queueing-in-the-linux-network-stack/)

---

# How packet flows via network stack (with tuning/debuging in mind)

### Disclaimer
this is my understanding, and I made a bunch of shortcuts in this notes
in purpouse. See some links for more detailed explanation:
- please start with **NETWORKING** chapters of Brendan Gregg books
- [https://blog.packagecloud.io/monitoring-tuning-linux-networking-stack-receiving-data](https://blog.packagecloud.io/monitoring-tuning-linux-networking-stack-receiving-data)
- [https://tungdam.medium.com/linux-network-ring-buffers-cea7ead0b8e8](https://tungdam.medium.com/linux-network-ring-buffers-cea7ead0b8e8)
- [https://optiver.com/working-at-optiver/career-hub/searching-for-the-cause-of-dropped-packets-on-linux/](https://optiver.com/working-at-optiver/career-hub/searching-for-the-cause-of-dropped-packets-on-linux/)
- [https://blog.tsunanet.net/2011/03/out-of-socket-memory.html](https://blog.tsunanet.net/2011/03/out-of-socket-memory.html)
- [https://www.coverfire.com/articles/queueing-in-the-linux-network-stack/](https://www.coverfire.com/articles/queueing-in-the-linux-network-stack/)

### ok, lesssgo
