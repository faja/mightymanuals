perf is really complex tool that can do prety awesome performance related
stuff: including timed sampling,

perf record -F 99 -a -g -- sleep. 30

hardware sampling (PMC)

...

event statistics and tracing

perf stat -e sched:sched_sched_process_exec -I 1000

and much much much more