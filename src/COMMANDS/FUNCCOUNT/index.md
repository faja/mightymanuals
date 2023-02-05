# syntax

```
funccount [options] eventname
```
where `eventname` is:
- `name` or `p:name` - instrument the kernel function called `name()`
- `lib:name` or `p:lib:name` - instrument user lvel function called `name()` in the library `lib`
- `path:name` - instrument user level function called `name()` in the file at `path`
- `t:system:name` - instrument tracepoint called `system:name`
- `u:lib:name` - instrument the USDT probe in library `lib` called `name`
- `*` - wildcard can be used to match any string
- `-r` - allows regular expressions to be used

run `funccount -h` for help

# quick examples
- is the `tcp_drop()` kernel function ever called? the below will trace invocation of `tcp_drop()` kernel function
    ```
    funccount tcp_drop
    ```

- what is the most frequent kernel VFS functions?
    ```
    funccount 'vfs_*'
    ```
- what is the rate of the user-level `pthread_mutex_lock()` function per second?
    ```
    funccount -i 1 c:pthread_mutex_lock
    ```

- what is the most frequent string function call from libc,system-wide?
    ```
    funccount 'c:str*'
    ```

- what is the most frequent syscall?
    ```
    funccount 't:syscalls:sys_enter_*'
    ```

# one liners
- `funccount 'vfs_*'` - count VFS kernel calls 
- `funccount 'tcp_*'` - count TCP kernel calls
- `funccount -i 1 'tcp_send*'` - count TCP send calls per second
- `funccount -i 1 't:block:*'` - show rate of block I/O events per second
- `funccount -i 1 t:sched:sched_process_fork` - show rate of ne processes per second
- `funccount -i 1 c:getaddrinfo` - show rate of libc getaddrinfo() per second
- `funccount 'go:os.*'` -  count all "os.*" calls in libgo
