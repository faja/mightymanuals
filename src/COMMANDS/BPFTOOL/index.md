# info

- [github](https://github.com/libbpf/bpftool)
- [amazing blog post](https://qmonnet.github.io/whirl-offload/2021/09/23/bpftool-features-thread/)
- [amazing video](https://www.youtube.com/watch?v=1EOLh3zzWP4)

# install

There are two important dependencies:
- `libbfd` - dependency needed for dumping JIT-compiled program instructions
- `skeletons` - to print the PIDs of the processes using programs, or to use bpftool prog profile

but I think binary must be built with them added as a features, hence for instance
on debian, when installed with apt-get, they are not there :/

check if binary includes them by running `bpftool version`


## debian

```sh
apt-get install -y bpftool
```

# usage

```bash
bpftool version  # to get version and what features are supported by installation

bpftool prog tracelog  # read the trace pipe
  # equivalent of `cat /sys/kernel/debug/tracing/trace_pipe`

bpftool feature probe kernel  # prints what BPF features our kernel supports, AWESOME!

# prog
bpftool prog list                      # list all bpf programs loaded
bpftool prog show id 540 --pretty      # show/describe particular program (by id)
bpftool prog show name hello --pretty  # show/describe particular program (by name)
bpftool prog dump xlated name hello    # print “translated” bytecode
bpftool prog dump jited name hello     # print MACHINE CODE

bpftool prog load hello.bpf.o /sys/fs/bpf/hello  # load prog/object into kernel
  # ^^ the last argument above is to pin bpf program to userspace
ls /sys/fs/bpf  # should list hello
llvm-objdump -d hello.bpf.o  # hint: prints bytecode before "translation"

bpftool prog pin id 27 /sys/fs/bpf/foo_prog  # pin already loaded program
rm /sys/fs/bpf/foo_prog                      # unpin
bpftool prog show --bpffs                    # print pinned paths if any

# map
bpftool map list
bpftool map dump name hello.bss
bpftool map dump name hello.rodata


# perf/tracing
bpftool perf show  # list all tracing eBPF programs,  currently attached
  # on the system to tracepoints, rawstracepoints, k[ret]probes, u[ret]probes

# net
bpftool net show              # listing programs related to network packets processing
bpftool net show dev <iface>  # filter per interface

# btf
bpftool btf list                  # list all the BTF data loadod into the kernel
bpftool btf dump id <id>          # inspect btf data content
bpftool btf dump map name config  # dump btf info about a map named "config"
bpftool btf dump prog <prog id>   # dump btf info about program

bpftool btf dump file /sys/kernel/btf/vmlinux format c > vmlinux.h # generate
  # kernel header file from the btf data
  # kernel must be compiled with CONFIG_DEBUG_INFO_BTF enabled
```

# my handy 1liners

```bash
# todo:D
```
