---

**[DISCLAIMER]**
- the only usage (at the time of writing) of containerd and **DIRECT** interaction
  is in K8S cluster from version 1.24 (since 1.24 docker is no longer there)
- containerd is of course still used under the hood by standalone docker
  installations, however we do not need to interact with it **DRECTLY**


# config and dirs
- `/etc/containerd/config.toml` - main config file
- `/var/lib/containerd/` - persistent data directory, called `root`
- `run/containerd/` - ephemeral directory, called `state`

# system

```
systemctl status containerd
journalctl -e -x -u  containerd -f -S today
systemd-cgls   # runtime.slice/containerd.service
```

# containerd command
```
containerd --version     # print version
containerd config dump   # current runtime config
```
