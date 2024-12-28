---

# Performance

- [go build in TRACING tool](./tracing.md)

---

**Four** things that causing pain in terms of performance
1. **IO**: latency on the **outside**: network, disk, device, etc., **inside**: mutexes, synchronisation
1. **MEMORY**: allocations on the heap, memory profiles are going to help us here
1. How data is being accessed and how we iterate over that data
1. **CPU**: algorithm efficiency, cpu profiles are going to help us here

---

**MICRO** leveel optimisation
- it's optimising a single function, take a single function, create a benchmark for it
  and run memory and cpu profiles, search for allocations and where cpu spends most time

**MACRO** leveel optimisation
- checking general health of the application, and gets low hanging fruit wins,
- check scheduling, garbage collections, leaking goroutines, check if data is being
  processed within reasonable amount of time
- start with running app with basic load, than move to some stress testing

---

# general
```sh
GODEBUG=schedtrace=1000 ./your_go_binary
# this will cause to print scheduling info to STDERR every 1000ms

GODEBUG=gctrace=1 ./your_go_binary
# this will cause to print info about GC every thim GC happens
```


# memory profiling (benchmark) (micro optimisation)
- create benchmark for your function
- run benchmark with memory profiling flags
```sh
go test -gcflags "-m -m" -run none -bench . -benchtime 3s -benchmem -memprofile m.out
  # -run none         - do not run any tests just benchmark stuff
  # -gcflags "-m -m"  - adds escape analysis
  # -memprofile m.out - adds memory profiling, with detailed info which line
  #                     allocation happens

go tool pprof -alloc_space m.out
  (pprof) list yourAwesomeFunctionNameYouWannaProfile
#  there are two columns: flat, cumulative
#    - flat - shows allocation that happens directly on that line
#    - cumulative - is the sum of all alocation that was caused by that line
#                   usually it happens not directly but down on the stack
#                   eg, we are calling some function that allocates a lot

go tool pprof -http :3000 -alloc_space m.out
# opens web ui for browshing the profile
```

# cpu profiling (benchmark) (macro optimisation)
- create benchmark for your function
- run benchmark with memory profiling flags
```sh
go test -run none -bench . -benchtime 3s -cpuprofile c.out
  # -run none          - do not run any tests just benchmark stuff
  # -cpuprofile c.out  - create cpu profiling

go tool pprof c.out
  (pprof) list yourAwesomeFunctionNameYouWannaProfile

go tool pprof -http :3000 c.out
# opens web ui for browshing the profile
```
