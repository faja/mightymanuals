#

- [k8s cgroups page](https://kubernetes.io/docs/concepts/architecture/cgroups/)

# `v1` vs `v2`
`v1` cgroups are deprecated, most distros defaults to `v2` since ~2022.
No point talking about `v1` any more.

Quick sanity check which cgroups are configured:

```sh
stat -fc %T /sys/fs/cgroup/

# outpus
#   cgroup2fs - v2
#   tmpfs     - v1
```

# cgroup driver
Various system components use "cgroup drivers" to deal with cgroups.
It's important that all componense use the same driver.

By components we can refer: CRI program like `containerd`, or `kubelet`.

DRIVERS:
- `cgroupfs` driver
- `systemd` cgroup driver

TLDR; if our init system is `systemd` - all components should be using `systemd` cgroup driver.

