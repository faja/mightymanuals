<span style="color:#ff4d94">**runqlat**</span> - measures CPU scheduler
latency, often called run queue latency (even when no longer implemented
using run queues).

### tldr usage

```sh
runqlat 10 1   # gather stats for 10 seconds and output once

# TODO: add more useage examples
```

---

### notes

- it is useful for identifying and quantifying issues of CPU saturation, where
  there is more demand for CPU resources than they can service
- the metric measured by `runqlat` is the time each thread (task) spends
  waiting for its turn on CPU
- <span style="color:#ffff66">**WARNING!**</span> USE WITH CAUTION - `runqlat`
  works by instrumenting scheduler wakeup and context switch events to
  determine the time from wakeup to running. These events can be very frequent
  on busy production systems, exceeding one million events per second.
  Even though BPF is optimized, at these rates even adding one microsecond
  per event can cause noticeable overhead
- it is useful to compare/run `runqlat` together with [runqlen](./../RUNQLEN/index.md)
  or [sar -uq 1](./../SAR/index.md) to get queue length as well

runqlat 10 1
Tracing run queue latency... Hit Ctrl-C to end.

     usecs               : count     distribution
         0 -> 1          : 3149     |                                        |
         2 -> 3          : 304613   |****************************************|
         4 -> 7          : 274541   |************************************    |
         8 -> 15         : 58576    |*******                                 |
        16 -> 31         : 15485    |**                                      |
        32 -> 63         : 24877    |***                                     |
        64 -> 127        : 6727     |                                        |
       128 -> 255        : 1214     |                                        |
       256 -> 511        : 606      |                                        |
       512 -> 1023       : 489      |                                        |
      1024 -> 2047       : 315      |                                        |
      2048 -> 4095       : 122      |                                        |
      4096 -> 8191       : 24       |                                        |
      8192 -> 16383      : 2        |                                        |