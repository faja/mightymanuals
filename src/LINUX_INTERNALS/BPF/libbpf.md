---

# info

**libbpf** - kinda "next-gen" BCC, library to build bpf programs in CO-RE manner
  (compile once, run everywere).


Libbpf supports building BPF `CO-RE`-enabled applications, which, in contrast to BCC,
do not require Clang/LLVM runtime being deployed to target servers and doesn't rely
on kernel-devel headers being available. :wooooo:

It **DOES** relay on kernel to be built with [BTF type information](https://www.kernel.org/doc/html/latest/bpf/btf.html)

<span style="color:#ff4d94">To check if kernel has BTF built-in:</span>
```sh
ls -la /sys/kernel/btf/vmlinux
```

---

Some links:
- [github](https://github.com/libbpf/libbpf)
- [BPF CO-RE reference guide](https://nakryiko.com/posts/bpf-core-reference-guide/)
- [BPF Portability and CO-RE](https://nakryiko.com/posts/bpf-portability-and-co-re/)
- [BCC to libbpf conversion](https://nakryiko.com/posts/bcc-to-libbpf-howto-guide/)
- [libbpf based perf/trace tools](https://github.com/iovisor/bcc/tree/master/libbpf-tools)

# install

## debian

```sh
apt-get install -y libbpf-dev

# to install just libbpf based perf/tracig tools
apt-get install -y libbpf-tools
```
