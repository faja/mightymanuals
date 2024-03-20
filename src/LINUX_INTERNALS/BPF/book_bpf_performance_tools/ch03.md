# Workload characterization
Suggested steps for performing workload characterization:
- Who is causing the load (eg PID, process name, UID, IP address)?
- Why is the load called (code path, stack trace, flame graph)?
- What is the load (IOPS, throughput, type)?
- How is the load changing over time (per-interval summaries)?

# Linux 60-second analysis
1. `uptime` ([uptime command](../../../COMMANDS/UPTIME/index.md))
1. `dmesg | tail` ([dmesg command](../../../COMMANDS/DMESG/index.md))
1. `vmstat 1` ([vmstat command](../../../COMMANDS/VMSTAT/index.md))
1. `mpstat -P ALL 1` ([mpstat command](../../../COMMANDS/MPSTAT/index.md))
1. `pidstat 1` ([pidstat command](../../../COMMANDS/PIDSTAT/index.md))
1. `iostat -xz 1` ([iostat command](../../../COMMANDS/IOSTAT/index.md))
1. `free -m` ([free command](../../../COMMANDS/FREE/index.md))
1. `sar -n DEV 1` ([sar command](../../../COMMANDS/SAR/index.md))
1. `sar -n TCP,ETCP 1` ([sar command](../../../COMMANDS/SAR/index.md))
1. `htop` ([htop command](../../../COMMANDS/HTOP/index.md))

# BCC tool checklist
1. `execsnoop` ([execsnoop command](../../../COMMANDS/EXECSNOOP/index.md))
1. `opensnoop` ([opensnoop command](../../../COMMANDS/OPENSNOOP/index.md))
1. `ext4slower` ([ext4slower command](../../../COMMANDS/EXT4SLOWER/index.md))
1. `biolatency` ([biolatency command](../../../COMMANDS/BIOLATENCY/index.md))
1. `biosnoop` ([biosnoop command](../../../COMMANDS/BIOSNOOP/index.md))
1. `cachestat` ([cachestat command](../../../COMMANDS/CACHESTAT/index.md))
1. `tcpconneCT` ([tcpconnect command](../../../COMMANDS/TCPCONNECT/index.md))
1. `tcpaccepT` ([tcpaccept command](../../../COMMANDS/TCPACCEPT/index.md))
1. `tcpretraNS` ([tcpretrans command](../../../COMMANDS/TCPRETRANS/index.md))
1. `runqlat` ([runqlat command](../../../COMMANDS/RUNQLAT/index.md))
1. `profile` ([profile command](../../../COMMANDS/PROFILE/index.md))
