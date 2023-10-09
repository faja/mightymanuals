---
- [code examples github](https://github.com/lizrice/learning-ebpf)
- play dir: `mightyplay/ebpf/01_book-learning-ebpf`

---

# ch01: What Is eBPF, and Why Is It Important?

na

---

# ch02: eBPF's "Hello World"

todo

---

# ch03: Anatomy of an eBPF Program

todo

---

# ch04: The bpf() System Call

- In general `bpf()` syscall has the following signature:
  ```
  int bpf(int cmd, union bpf_attr *attr, unsigned int size);
  ```
  three arguments are: the **command**, **attributes** (any attributes we wanna pass to the command), **size** (of the attributes).

  Examples:
    - `bpf(BPF_BTF_LOAD, {btf="\237\353\1\0...}, 128) = 3` - load BTF (BPF Type Format) data
    - `bpf(BPF_MAP_CREATE, {map_type=BPF_MAP_TYPE_HASH, key_size=4, value_size=12, max_entries=10240... map_name="config", ...btf_fd=3,...}, 128) = 5` - create BPF map of type HASH
    - `bpf(BPF_MAP_CREATE, {map_type=BPF_MAP_TYPE_RINGBUF, key_size=0, value_size=0, max_entries=4096, ... map_name="output", ...}, 128) = 4` - create bpf ring buffer
    - `bpf(BPF_PROG_LOAD, {prog_type=BPF_PROG_TYPE_KPROBE, insn_cnt=44, insns=0xffffa836abe8, license="GPL", ... prog_name="hello", ... expected_attach_type=BPF_CGROUP_INET_INGRESS, prog_btf_fd=3,...}, 128) = 6` - load BPF program into the kernel
    - `bpf(BPF_MAP_UPDATE_ELEM, {map_fd=5, key=0xffffa7842490, value=0xffffa7a2b410, flags=BPF_ANY}, 128) = 0` - update map element from the userspace

- BPF objects (programs, maps, debug info) are being created/loaded into kernel and stays
there, as long as the reference counter is > 0. Reference counter is increased whenever
a userspace program creates FD (file descriptor) etc.. Once the counter drops to 0, program (or actually
any BPF object) is deleted from kernel.

See [blogpost](https://facebookmicrosites.github.io/bpf/blog/2018/08/31/object-lifetime.html) for detailed explanation.

---

# ch05: CO-RE, BTF, and Libbpf
