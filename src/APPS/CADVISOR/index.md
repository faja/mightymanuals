# cadvisor

[https://github.com/google/cadvisor](https://github.com/google/cadvisor)

There is not much about it. This is how I tend to start it:

```bash
/usr/bin/cadvisor -logtostderr \
                  -docker_only=true \
                  -store_container_labels=false \
                  -whitelisted_container_labels=stack \
                  -disable_metrics=accelerator,advtcp,cpu_topology,hugetlb,memory_numa,percpu,referenced_memory,resctrl
```
