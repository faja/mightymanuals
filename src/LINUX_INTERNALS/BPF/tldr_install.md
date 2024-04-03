- [github.com - bcc install](https://github.com/iovisor/bcc/blob/master/INSTALL.md)
- [github.com - bpftrace install](https://github.com/bpftrace/bpftrace/blob/master/INSTALL.md)

---

# kernel version check
Must be > 4.9

# kernel config check
I'm not entirely sure what options are really needed and which are optional for
what, but I guess I'll find out sooner or later...

Copy paste my own sh script to pretty print what is there and what is missing...

Kernel config options are taken from official `bcc` and `bpftrace` install github
pages.

<details><summary><span style="color:#ff4d94">bpf_kernel_config_check.sh</span></summary>

```sh
#!/bin/bash -

# kernel configs:
# bcc      : https://github.com/iovisor/bcc/blob/master/INSTALL.md#kernel-configuration
# bpftrace : https://github.com/bpftrace/bpftrace/blob/master/INSTALL.md#linux-kernel-requirements
#

KERNEL_CONFIG_FILE=${1}

if test -z "${KERNEL_CONFIG_FILE}"; then
  echo usage: "${0}" KERNEL_CONFIG_FILE
  exit 1
fi

RED="\e[31;1m"
GREEN="\e[32;1m"
NORMAL="\e[0m"

ok() {
  echo -e " [${GREEN}OK${NORMAL}]"
}

nok() {
  echo -e " [${RED}NOK${NORMAL}]"
}

check() {
  echo -n "# checking ${1}"
  if grep -q "${1}" "${KERNEL_CONFIG_FILE}"; then
    ok
  else
    nok
  fi
}

echo '## REQUIRED CONFIGS'
check CONFIG_BPF=y
check CONFIG_BPF_SYSCALL=y
check CONFIG_BPF_JIT=y
check CONFIG_HAVE_EBPF_JIT=y
check CONFIG_BPF_EVENTS=y
echo

echo '## FOR BPFTRACE [optional]'
check CONFIG_FTRACE_SYSCALLS=y
check CONFIG_FUNCTION_TRACER=y
check CONFIG_HAVE_DYNAMIC_FTRACE=y
check CONFIG_DYNAMIC_FTRACE=y
check CONFIG_HAVE_KPROBES=y
check CONFIG_KPROBES=y
check CONFIG_KPROBE_EVENTS=y
check CONFIG_ARCH_SUPPORTS_UPROBES=y
check CONFIG_UPROBES=y
check CONFIG_UPROBE_EVENTS=y
check CONFIG_DEBUG_FS=y
echo

echo '## FOR BCC NETWORKING [optional]'
check CONFIG_NET_CLS_BPF=m
check CONFIG_NET_ACT_BPF=m
check CONFIG_NET_SCH_SFQ=m
check CONFIG_NET_ACT_POLICE=m
check CONFIG_NET_ACT_GACT=m
check CONFIG_DUMMY=m
check CONFIG_VXLAN=m
echo

echo '## kernel headers through /sys/kernel/kheaders.tar.xz [optional]'
check CONFIG_IKHEADERS=y
```

</details>

# packages

Ok, packages are distro specific, so:

## alpine
## debian
## aws linux 2
