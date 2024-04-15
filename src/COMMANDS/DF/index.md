---

```sh
df -h -T                      # print filesystem type
df -h -x overlay -x tmpfs     # exclude overlay and tmpfs filesystems
  # useful for NOT printing container mounts
df -h -t xfs                  # include xfs type only
```
