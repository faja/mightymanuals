---

shows various network stats, I don't find thid tool useful at all

```sh
nstat     # show stats since last stat reset, and RESET the stats
nstat -s  # show stats since last stat reset, do NOT reset the stats
nstat -sz # show also entries with ZERO activity

nstat -sr # RECOVER stats since boot

# example
nstat -z | grep -e TcpActiveOpens -e TcpPassiveOpens
```
