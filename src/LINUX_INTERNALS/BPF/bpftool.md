# info

- [github](https://github.com/libbpf/bpftool)

# install
## debian

```sh
apt-get install -y bpftool
```

# examples
```sh
bpftool prog load hello.bpf.o /sys/fs/bpf/hello  # load prog/object into kernel
  # ^^ the last argument above is to pin bpf program to userspace
ls /sys/fs/bpf  # should list hello

bpftool prog list                    # list all bpf programs loaded
bpftool prog show id 540 --pretty    # show/describe particular program (by id)

bpftool prog dump xlated name hello  # print “translated” bytecode
  # once it is loaded, passed verifier (and possibly modified)
  # this is equivalet of `llvm-objdump -S hello.bpf.o`

bpftool prog dump jited name hello   # aaaand finally this is the MACHINE CODE

bpftool net attach xdp id 540 dev eth0  # attach to the network interface
bpftool net list                        # list network bpf programs
bpftool net detach xdp dev eth0         # detach

bpftool prog show name hello  # even we detached, the program is still loaded
rm /sys/fs/bpf/hello          # unpinning, removes all the references
  # hence, the program will be unloaded automagically
bpftool prog show name hello  # should return nothing

# other, map related commands
bpftool map list
bpftool map dump name hello.bss
bpftool map dump name hello.rodata
```
