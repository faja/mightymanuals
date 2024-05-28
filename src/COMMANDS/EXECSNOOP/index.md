---

`execsnoop` shows new process execution for every `execve(2)` syscall.

---

```sh
execsnoop

execsnoop -t       # prints time since execsnoop started
execsnoop -T       # prints time/date

execsnoop -P PPID  # prints only processes started by PPID
execsnoop -u USER  # prints only processes started by user

execsnoop -n bash  # prints only commands containing "bash"
execsnoop -l test  # prints only if arguments contain "test"
```
