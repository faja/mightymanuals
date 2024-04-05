---

BCCTools are set of performance/tracing tools that are build on top of BCC.
They live in the same repo as BCC, and usually are packed together/next to BCC.

As a rule of thumb
  - `bcctools` tools are heavier, includes a lot of options, etc...
  - `bpftrace` tools are lighter, often oneliners, etc...

NOTE: in the bcc git repo there are actually two directories:
- [tools](https://github.com/iovisor/bcc/tree/master/tools) - bcc based, python programs
- [libbpf-tools](https://github.com/iovisor/bcc/tree/master/libbpf-tools) - libbpf based, c programs
- [list of all tools](https://github.com/iovisor/bcc/tree/master#tools)

<span style="color:#ff4d94">**NOTE!!**</span> because libbpf based tools doesn't
require linux headers and compler I think current trend is to use them instead of
bcc python ones (see [libbpf](./libbpf.md) for details).

# install

## debian
```sh
# to install BCC python tools
apt-get install -y bpfcc-tools libbpfcc libbpfcc-dev linux-headers-$(uname -r)

# to install libbpf c tools
apt-get install -y libbpf-tools
```

# List of commands I do have man page for
- ...TODO
- [argdist](../../COMMANDS/ARGDIST/index.md)
- [funccount](../../COMMANDS/FUNCCOUNT/index.md)
- [stackcount](../../COMMANDS/STACKCOUNT/index.md)
- [tcpconnect](../../COMMANDS/TCPCONNECT/index.md)
- [trace](../../COMMANDS/TRACE/index.md)
