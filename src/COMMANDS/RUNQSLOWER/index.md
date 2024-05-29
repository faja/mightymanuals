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
