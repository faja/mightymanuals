---
- [code examples github](https://github.com/lizrice/learning-ebpf)
- play dir: `mightyplay/ebpf/01_book-learning-ebpf`


---

# ch01: What Is eBPF, and Why Is It Important?

na


---


# ch02: eBPF's "Hello World"

- hello world example, the entrie python (bcc) program looks like
    ```python
    #!/usr/bin/python3
    from bcc import BPF

    program = r"""
    int hello(void *ctx) {
        bpf_trace_printk("Hello World!");
        return 0;
    }
    """

    b = BPF(text=program)
    syscall = b.get_syscall_fnname("execve")
    b.attach_kprobe(event=syscall, fn_name="hello")

    b.trace_print()
    ```

- to see all examples, goto: `mightyplay/ebpf/01_book-learning-ebpf/src/ch02`

- `/sys/kernel/debug/tracing/trace_pipe` - shared trace pipe for all bpf programs

---


# ch03: Anatomy of an eBPF Program

- BPF program goes through 3 stages:
    - first we do have a program written in `C` - the source code
    - then it is being compiled into "Bytecode", the result file of such compilation
      is often called an "Object File"
    - then once the object file is loaded into kernel it is being JITted into
      "Machine Code" (assembly)
    ```
    |-------------|   compilation   |---------------|  JIT   |--------------|
    | (limited) C | --------------> | eBPF bytecode | -----> | machine code |
    |-------------|                 |---------------|        |--------------|
    ```

- as a comparison to the previous python/bcc based program, here is the C hello world
  for a network interface, `hello.bpf.c`:
    ```c
    #include <linux/bpf.h>
    #include <bpf/bpf_helpers.h>

    int counter = 0;

    SEC("xdp")
    int hello(struct xdp_md *ctx) {
        bpf_printk("Hello World %d", counter);
        counter++;
        return XDP_PASS;
    }

    char LICENSE[] SEC("license") = "Dual BSD/GPL";
    ```

- `hello.bpf.c` -> once compiled (with `clang`), becomes `hello.bpf.o`, ELF (Executable and Linkable Format)
    ```sh
    % file hello.bpf.o
    hello.bpf.o: ELF 64-bit LSB relocatable, eBPF, version 1 (SYSV), with debug_info,
    not stripped
    ```

- which can be examine with `llvm-objdump`, this is basically the eBPF bytecode!
    ```
    % llvm-objdump -S hello.bpf.o

    hello.bpf.o: file format elf64-bpf

    Disassembly of section xdp:

    0000000000000000 <hello>:
    ; bpf_printk("Hello World %d", counter");
     0: 18 06 00 00 00 00 00 00 00 00 00 00 00 00 00 00 r6 = 0 ll
     2: 61 63 00 00 00 00 00 00 r3 = *(u32 *)(r6 + 0)
     3: 18 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 r1 = 0 ll
     5: b7 02 00 00 0f 00 00 00 r2 = 15
     6: 85 00 00 00 06 00 00 00 call 6
    ; counter++;
     7: 61 61 00 00 00 00 00 00 r1 = *(u32 *)(r6 + 0)
     8: 07 01 00 00 01 00 00 00 r1 += 1
     9: 63 16 00 00 00 00 00 00 *(u32 *)(r6 + 0) = r1
    ; return XDP_PASS;
     10: b7 00 00 00 02 00 00 00 r0 = 2
     11: 95 00 00 00 00 00 00 00 exit
    ```

- further, such object file can be loaded into kernel with `bpftool` (see [bpftool](./bpftool.md))
    ```sh
    % bpftool prog load hello.bpf.o /sys/fs/bpf/hello
    # ^^ the last argument above is to pin bpf program to userspace
    % ls /sys/fs/bpf
    hello
    ```

- once it is loaded we can do pretty cool stuff with it using `bpftool`
  (again, see [bpftool](./bpftool.md) for tool desc)
    ```sh
    % bpftool prog list                    # list all bpf programs loaded
    % bpftool prog show id 540 --pretty    # show/describe particular program

    % bpftool prog dump xlated name hello  # print “translated” bytecode
      # once it is loaded, passed verifier (and possibly modified)
      # this is equivalet of `llvm-objdump -S hello.bpf.o`

    % bpftool prog dump jited name hello   # aaaand finally this is the MACHINE CODE

    % bpftool net attach xdp id 540 dev eth0  # attach to the network interface
    % bpftool net list                        # list network bpf programs
    % bpftool net detach xdp dev eth0         # detach
    ```

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

- TODO

---

# ch06: The eBPF Verifier

- [kernel bpf verifier docs](https://docs.kernel.org/bpf/verifier.html)

---

# ch07: eBPF Program and Attachment Types

---
