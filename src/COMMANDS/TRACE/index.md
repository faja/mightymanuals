<span style="color:#ff4d94">**trace**</span> - tool for per-event tracing from
many different sources: kprobes, uprobes, tracepoints and USDT probes, can answer questions:
- what are the arguments when a kernel- or user-level function is called?
- what is the return value of this function? is it failing?
- how is this function called? what is the user- or kernel-level stack trace?


# syntax

```
trace [options] probe [probe ...]
```
syntax for probe
```
eventname(signature) (boolean filter) "format string", arguments
```
where `eventname` is:
- `name` or `p:name` - instrument the kernel function called `name()`
- `r::name` - instrument the return of the kernel function called `name()`

- `lib:name` or `p:lib:name` - instrument user lvel function called `name()` in the library `lib`
- `r:lib:name` - instrument the return of the user-level function `name()` in the library `lib`

- `path:name` - instrument user level function called `name()` in the file at `path`
- `r:path:name` - instrument the return of the user level function called `name()` in the file at `path`

- `t:system:name` - instrument tracepoint called `system:name`
- `u:lib:name` - instrument the USDT probe in library `lib` called `name`
- `*` - wildcard can be used to match any string
- `-r` - allows regular expressions to be used

run `trace -h` for help

# one liners
```sh
trace 'do_sys_open "%s", arg2'              # trace the kernel do_sys_open() function with the filename
trace 'r::do_sys_open "ret: %d", retval'    # trace the return of the kernel do_sys_open() function and print the return value
trace -U 'do_nanosleep "mode: %d", arg2'    # trace do_nanosleep() with mode and user-level stacks
trace 'pam:pam_start "%s: %s", arg1, arg2'  # trace authentication requests via the pam library
```
