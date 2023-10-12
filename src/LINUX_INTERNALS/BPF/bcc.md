# info

BCC - BPF Compiler Collection aka BPF toolkit

- [github](https://github.com/iovisor/bcc)

- <span style="color:#ff4d94">**NOTE!!**</span> recently there is a trend to replace it with libbpf
    - see [bcc -> libbpf](https://nakryiko.com/posts/bcc-to-libbpf-howto-guide/) blog post
    - see dedicated [libbpf](./libbpf.md) page

- [bcctools](https://github.com/iovisor/bcc/tree/master#tools) are part of BCC toolkit
    - see dedicated [bcctools](./bcctools.md) page

- worth having a look
    - [official short tutorial](https://github.com/iovisor/bcc/blob/master/docs/tutorial.md)
    - [official python dev tutorail](https://github.com/iovisor/bcc/blob/master/docs/tutorial_bcc_python_developer.md)

# install

[github INSTALL.md](https://github.com/iovisor/bcc/blob/master/INSTALL.md)

### kernel config
quick check list
```sh
# grep /boot/config-* or grep /proc/config.gz

grep 'CONFIG_BPF=y' /boot/config-*
grep 'CONFIG_BPF_SYSCALL=y' /boot/config-*
grep 'CONFIG_BPF_JIT=y' /boot/config-*
grep 'CONFIG_HAVE_BPF_JIT=y' /boot/config-*   # for kernel < 4.7
grep 'CONFIG_HAVE_EBPF_JIT=y' /boot/config-*  # for kernel > 4.7

grep 'CONFIG_NET_CLS_BPF=m' /boot/config-*  # optional, for tc filters
grep 'CONFIG_NET_ACT_BPF=m' /boot/config-*  # optional, for tc actions
grep 'CONFIG_BPF_EVENTS=y' /boot/config-*   # optional, for kprobes

grep 'CONFIG_IKHEADERS=y' /boot/config-*  # it means kernel headers are compiled
                                          # into kernel, unfortunately,
                                          # this is usually not enabled,
                                          # if that's the case, you have to
                                          # install `linux-headers-$(uname -r)`


# optional
grep 'CONFIG_NET_SCH_SFQ=m' /boot/config-*
grep 'CONFIG_NET_ACT_POLICE=m' /boot/config-*
grep 'CONFIG_NET_ACT_GACT=m' /boot/config-*
grep 'CONFIG_DUMMY=m' /boot/config-*
grep 'CONFIG_VXLAN=m' /boot/config-*
```

### packages
#### debian
```sh
apt-get update -y
apt-get install -y bpfcc-tools libbpfcc libbpfcc-dev linux-headers-$(uname -r)
```
