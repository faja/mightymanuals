---

quick links
- [github.com/iovisor/bpftrace](https://github.com/iovisor/bpftrace)
- [github.com/iovisor/bpftrace/blob/master/docs/tutorial_one_liners.md](https://github.com/iovisor/bpftrace/blob/master/docs/tutorial_one_liners.md)

---

`bpftrace` (similary to `BCC`) requires some kernel `CONFIG_` options to be set, see [INSTALL.md](https://github.com/iovisor/bpftrace/blob/master/INSTALL.md) for all the details.

---

- [network](./network.md)

---

# tldr; examples; one-liners
- list probes
    ```sh
    bpftrace -l 'tracepoint:syscalls:sys_enter_*'
    ```

- show who is executing what
    ```sh
    bpftrace -e 'tracepoint:syscalls:sys_enter_execve { printf("%s -> %s\n", comm, str(args->filename)); }'
    ```

- show new processes with arguments
    ```sh
    bpftrace -e 'tracepoint:syscalls:sys_enter_execve { join(args->argv); }'
    ```

- show files opened using openat() by process
    ```sh
    bpftrace -e 'tracepoint:syscalls:sys_enter_openat { printf("%s %s\n", comm, str(args->filename)); }'
    ```

- count syscalls by program
    ```sh
    bpftrace -e 'tracepoint:raw_syscalls:sys_enter { @[comm] = count(); }'
    ```

- count syscalls by syscall probe name
    ```sh
    bpftrace -e 'tracepoint:syscalls:sys_enter_* { @[probe] = count(); }'
    ```

- count syscalls by process
    ```sh
    bpftrace -e 'tracepoint:raw_syscalls:sys_enter { @[pid, comm] = count(); }'
    ```

- show the total read bytes by process
    ```sh
    bpftrace -e 'tracepoint:syscalls:sys_exit_read /args->ret/ { @[comm] = sum(args->ret); }'
    ```

- show the read size distribution by process
    ```sh
    bpftrace -e 'tracepoint:syscalls:sys_exit_read { @[comm] = hist(args->ret); }'
    ```

- show the trace disk I/O size by process
    ```sh
    bpftrace -e 'tracepoint:block:block_rq_issue { printf("%d %s %d\n", pid, comm, args->bytes); }'
    ```

- count pages paged in by process
    ```sh
    bpftrace -e 'software:major-faults:1 { @[comm] = count(); }'
    ```

- count page faults by process
    ```sh
    bpftrace -e 'software:faults:1 { @[comm] = count(); }'
    ```

- profile user-level stacks at 49Hertz for PID 189
    ```sh
    bpftrace -e 'profile:hz:49 /pid == 189/ { @[ustack] == count(); }'
    ```

# Programming

### listing probes
```sh
bpftrace -l         # lists all probes, pipe it to grep to regex matching
bpftrace -l '...'   # lists all probes filtered by provided filter,
                    #   useful if you know what you are looking for, eg:
bpftrace -l 'tracepoint:syscalls:sys_enter_*'
```

### emiting BPF instructions
```sh
bpftrace -v script.bt     # -v empits BPF instructions
```

### bpftrace scripting

`bpftrace` can be also used to write "scripts", eg:

```sh
#!/usr/local/bin/bpftrace

// this program times vfs_read()

kprobe:vfs_read
{
  @start[tid] = nsecs;
}

kretprobe:vfs_read
/@start[tid]/
{
  $duration_us = (nsecs - @start[tid]) / 1000;
  @us = hist($duration_us);
  delete(@start[tid]);
}
```
