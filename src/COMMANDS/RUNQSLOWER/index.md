<span style="color:#ff4d94">**runqslower**</span> - pritns tasks/threads that
waits too long on the run queue

### tldr usage

```sh
runqlen 10 1   # gather stats for 10 seconds and output once

runqlen -C     # show per-CPU histogram, useful for checking scheduler balance
```

---

### notes

- <span style="color:#ffff66">**WARNING!**</span> USE WITH CAUTION - the
  overhead is similar to [runqlat](./../RUNQLAT/index.md) due to the cost
  of the kprobes, even while `runqslower` is not printing any output


### example output

# runqslower
Tracing run queue latency higher than 10000 us
TIME     COMM             PID           LAT(us)
17:42:49 python3          4590            16345
17:42:50 pool-25-thread-  4683            50001
17:42:53 ForkJoinPool.co  5898            11935
17:42:56 python3          4590            10191
17:42:56 ForkJoinPool.co  5912            13738
17:42:56 ForkJoinPool.co  5908            11434
17:42:57 ForkJoinPool.co  5890            11436
17:43:00 ForkJoinPool.co  5477            10502
17:43:01 grpc-default-wo  5794            11637
17:43:02 tomcat-exec-296  6373            12083
[...]