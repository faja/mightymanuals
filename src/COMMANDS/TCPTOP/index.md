---

`tcptop` - nice **BPF** based tool to see what TCP connections are happening
           on the system

```sh
tcptop  # by default refresh every 1 second, "top" like behaviour

tcptop -p ${PID}  # trace PID only
tcptop -C        # --noclear, do not clear the screen
```
