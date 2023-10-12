# info

- [github](https://github.com/libbpf/bpftool)
- [amazing blog post](https://qmonnet.github.io/whirl-offload/2021/09/23/bpftool-features-thread/)

# install

NOTE: `libbfd` is dependency needed for dumping JIT-compiled program instructions

## debian

```sh
apt-get install -y bpftool
```

# usage

```bash
# prog
bpftool prog list                      # list all bpf programs loaded
bpftool prog show id 540 --pretty      # show/describe particular program (by id)
bpftool prog show name hello --pretty  # show/describe particular program (by name)
bpftool prog dump xlated name hello    # print “translated” bytecode
bpftool prog dump jited name hello     # print MACHINE CODE

bpftool prog load hello.bpf.o /sys/fs/bpf/hello  # load prog/object into kernel
  # ^^ the last argument above is to pin bpf program to userspace
ls /sys/fs/bpf  # should list hello


# map
bpftool map list
bpftool map dump name hello.bss
bpftool map dump name hello.rodata


# net
bpftool net attach xdp id 540 dev eth0  # attach to the network interface
bpftool net list                        # list network bpf programs
bpftool net detach xdp dev eth0         # detach

```
