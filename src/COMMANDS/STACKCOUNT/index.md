# syntax

```
stackcount [options] eventname
```
where `eventname` is:
- `name` or `p:name` - instrument the kernel function called `name()`
- `lib:name` or `p:lib:name` - instrument user lvel function called `name()` in the library `lib`
- `path:name` - instrument user level function called `name()` in the file at `path`
- `t:system:name` - instrument tracepoint called `system:name`
- `u:lib:name` - instrument the USDT probe in library `lib` called `name`
- `*` - wildcard can be used to match any string
- `-r` - allows regular expressions to be used

run `stackcount -h` for help

# quick examples
- identify the code paths that led to `ktime_get()` function:
    ```
    stackcount ktime_get
    ```

- same as above but with extra information about process name and PID:
    ```
    stackcount -P ktime_get
    ```

- trace `ktime_get()` for 10 seconds (`-D 10`) with per-process stacks (`-P`) and generate flame graph (`-f`)
    ```
    stackcount -f -P -D 10 ktime_get > out.stackcount01.txt
    git clone http://github.com/brendangregg/FlameGraph && cd FlameGraph
    ./flamegraph.pl --hash --bgcolors=grey < ../out.stackcount01.txt > out.stackcount01.svg
    ```

# one liners
- `stackcount t:block:block_rq_insert` - count stack traces that created block I/O
- `stackcount ip_output` - count stack traces that led to sending IP packets
- `stackcount -P ip_output` - count stack traces that led to sending IP packets, with the responsible PID
- `stackcount t:sched:sched_switch` - count stack traces that led to the thread blocking and moving off-CPU
- `stackcount t:syscall:sys_enter_read` - count stack traces that led to the read() syscall
