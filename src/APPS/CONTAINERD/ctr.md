**[IMPORTANT]** `containerd` has a concept of namespaces, all container related
subcommands must include `--namespace` flag

- list all namespaces
```sh
ctr namespaces list                           # ctr ns ls
```

- list images
```sh
ctr --namespace k8s.io images list            # ctr -n k8s.io i ls
```

- list containers
```sh
ctr --namespace k8s.io containers list        # ctr -n k8s.io c ls
```

- exec into container
```sh
ctr -n k8s.io tasks exec -t --exec-id XXX ${CONTAINER_ID} /bin/bash
# exec-id is just a random string/id
```

- logs...hmmm...not really sure, but there is no way of getting logs from a running task,
    similar to `docker logs`
    - on K8S node, the logs can be read directly from disk
    `/var/log/pods/...` with a friendly pod name

    - or by container ID, `ls -la /var/log/containers | grep ${CONTAINER_ID}`, that symlinks to `/var/log/pods/...`

