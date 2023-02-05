# syntax

```
argdist {-C|-H} [options] probe
```
where:
- `-C` - frequency count
- `-H` power-of-two histogram

syntax for probe is 
```
eventname(signature)[:type[,type...]:ex[r[,expr...][:filter]][$label]`
```

run `argdist -h` for help

# one liners
- `argdist -H 'r::__tcp_select_window() :int:$retval'` - histogram of return values of `__tcp_select_window()` kernel function
- `argdist -H 'r::vfs_read()'` -  histogram of results (sizes) returned by the kernel function vfs_read()
- `argdist -p 1005 -H 'r:c:read()'` - histogram of results (sizes) returned by the user-level libc read() for PID 1005
- `argdist -C 't:raw_syscalls:sys_enter():int:args->id'` - count syscalls by syscall ID
