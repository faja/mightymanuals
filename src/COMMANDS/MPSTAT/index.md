<span style="color:#ff4d94">**mpstat**</span> - can be used to examine per-CPU metrics

```sh
mpstat           # average across all cpus
mpstat -P ALL    # seperate per cpu
mpstat -P ALL 1  # print every second
```

```sh
# mpstat -P ALL 1
Linux 6.1.0-10-amd64 (bookworm)         05/28/24        _x86_64_        (2 CPU)

20:56:30     CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest  %gnice   %idle
20:56:31     all   25.82    0.00   12.64    6.04    0.00    1.10    0.00    0.00    0.00   54.40
20:56:31       0   36.78    0.00    9.20    0.00    0.00    0.00    0.00    0.00    0.00   54.02
20:56:31       1   15.79    0.00   15.79   11.58    0.00    2.11    0.00    0.00    0.00   54.74

20:56:31     CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest  %gnice   %idle
20:56:32     all   16.67    0.00    9.26    6.79    0.00    3.70    0.00    0.00    0.00   63.58
20:56:32       0   29.17    0.00    8.33   13.89    0.00    6.94    0.00    0.00    0.00   41.67
20:56:32       1    6.67    0.00   10.00    1.11    0.00    1.11    0.00    0.00    0.00   81.11
```
