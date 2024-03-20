---

# tldr

```sh
bpftrace -e 'tracepoint:syscalls:sys_enter_open { printf("%s %s\n", comm, str(args->filename)); }'
bpftrace -l 'tracepoint:syscalls:sys_enter_open*'
bpftrace -e 'tracepoint:syscalls:sys_enter_open* { @[probe] = count(); }'

bpftrace -v script.bt     # -v empits BPF instructions
```
