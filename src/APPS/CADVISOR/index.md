# cadvisor

[https://github.com/google/cadvisor](https://github.com/google/cadvisor)

There is not much about it. This is how I tend to start it:

```bash
/usr/bin/cadvisor -logtostderr \
                  -docker_only=true \
                  -store_container_labels=false \
                  -whitelisted_container_labels=stack \
                  -disable_metrics=advtcp,cpu_topology,hugetlb,memory_numa,percpu,referenced_memory,resctrl
```

and here is my compose.yaml to start cadvisor
```yaml
---
name: cadvisor
services:
  cadvisor:
    container_name: cadvisor
    image: gcr.io/cadvisor/cadvisor:v0.49.2
    entrypoint:
      - cadvisor
    command:
      - -logtostderr
      - -docker_only=true
      - -store_container_labels=false
      - -whitelisted_container_labels=stack
      - disable_metrics=advtcp,cpu_topology,hugetlb,memory_numa,percpu,referenced_memory,resctrl
    restart: unless-stopped
    privileged: true
    pid: host  # to get process and fd stats
    logging:
      options:
        tag: "{{ .Name }}"
        labels: stack
    ports:
      - 9110:8080
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:rw
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
      - /dev/disk/:/dev/disk:ro
    labels:
      stack: cadvisor
```

for more details see [ansible role](https://github.com/faja/mightyplay/tree/master/ansible/roles/cadvisor)
