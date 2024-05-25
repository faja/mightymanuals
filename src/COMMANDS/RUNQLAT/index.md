6.3.3 runqlat
runqlat(8)8 is a BCC and bpftrace tool for measuring CPU scheduler
latency, often called run queue latency (even when no longer implemented
using run queues). It is useful for identifying and quantifying issues
of CPU saturation, where there is more demand for CPU resources than they
can service. The metric measured by runqlat(8) is the time each thread (task)
spends waiting for its turn on CPU


runqlat(8) works by instrumenting scheduler wakeup and context switch events to
determine the time from wakeup to running. These events can be very frequent on
busy production systems, exceeding one million events per second. Even though BPF
is optimized, at these rates even adding one microsecond per event can cause noticeable
overhead. Use with caution.


As a simple exercise, if you had a context switch rate of 1M/sec across
a 10-CPU system, adding 1 microsecond per context switch would consume
10% of CPU resources (100% × (1 × 1000000 / 10 × 1000000)).



NOTE: comparke with q length!
This particular issue is straightforward to identify from other tools and metrics. For example, sar(1) can show CPU utilization (-u) and run queue metrics (-q):

Click here to view code image


# sar -uq 1
Linux 4.18.0-virtual (...)   01/21/2019    _x86_64_      (36 CPU)

11:06:25 PM     CPU     %user     %nice   %system   %iowait    %steal     %idle
11:06:26 PM     all     88.06      0.00     11.94      0.00      0.00      0.00

11:06:25 PM   runq-sz  plist-sz   ldavg-1   ldavg-5  ldavg-15   blocked
11:06:26 PM        72      1030     65.90     41.52     34.75         0
[...]

This sar(1) output shows 0% CPU idle and an average run queue size of 72 (which includes both running and runnable)—more than the 36 CPUs available.

Chapter 15 has a runqlat(8) example showing per-container latencySee Chapter 18 for some real measurements of BPF overhead, which is
typically much less than one microsecond per event. 





