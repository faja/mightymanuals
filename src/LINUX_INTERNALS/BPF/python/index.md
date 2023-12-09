---

# play
-> `mightyplay/ebpf/02_my_python`

# quick start
```
apt-get install -y linux-headers-$(uname -r) python3-bpfcc

cat <<EOT > ebpf.py
#!/usr/bin/python3
from bcc import BPF
BPF(text='int kprobe__sys_clone(void *ctx) { bpf_trace_printk("Hello, World!\\n"); return 0; }').trace_print()
> EOT

python ebpf.py
```
