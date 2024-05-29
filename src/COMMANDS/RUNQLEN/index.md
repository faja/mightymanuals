<span style="color:#ff4d94">**runqlen**</span> - samples the length of the CPU
run queues, counting how many tasks are waiting

### tldr usage

```sh
runqlen 10 1   # gather stats for 10 seconds and output once

runqlen -C     # show per-CPU histogram, useful for checking scheduler balance
```

### example output
```sh
# runqlen 10 1
Sampling run queue length... Hit Ctrl-C to end.

     runqlen       : count     distribution
        0          : 47284    |****************************************|
        1          : 211      |                                        |
        2          : 28       |                                        |
        3          : 6        |                                        |
        4          : 4        |                                        |
        5          : 1        |                                        |
        6          : 1        |                                        |
```

---

### notes

- <span style="color:#ffff66">**important**</span> `runqlen` works is by
  sampling run queues at **99 Hertz** (`runqlat` traces scheduler events)
- it is kind a cheaper version of [runqlat](./../RUNQLAT/index.md), and should
  be exec rather as a helper to it

