- [dockerfile](./DOCKERFILE/index.md)
- [compose](./COMPOSE/index.md)
- [docker image sha madness](./SHA/index.md)

# basic docker usage

## listing containers
```sh
# custom output
## include labels
docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Labels}}"
## include particular label
docker ps --format '{{.ID}}\t{{ .Names }}\t{{ .Label "some.label.with.dots.xxx" }}'


# filter by label
docker ps --filter label=labelKEY        # label exists
docker ps --filter label=labelKEY=value1 # label must be set exactly to `value1`
```

# below is all todo

- deubugging "slim" containers
    ```sh
    # net and pid
    docker run --rm -it \
      --net container:CONTAINER_NAME \
      --pid container:CONTAINER_NAME \
      alpine:3 sh

    # rootfs
    CPID=$(docker inspect -f '{{ .State.Pid }}' CONTAINER_NAME)
    PPID=$(awk '{ print $4 }' /proc/${CPID}/stat )
    ll /proc/${PPID}/root/
    ```

---
```sh
docker container inspect xyz | jq '.[] | .Config.Labels'
```

---
```sh
docker manifest inspect -v ${IMAGE} | jq .Descriptor.digest
```

---
```sh
```

---

### how to move docker volume from one host to another

```bash
# on node02
mkdir /tmp/backup
chown ec2-user:ec2-user /tmp/backup

# on node01
VOLUME_NAME=...
VOLUME_MOUNT_PATH=...

mkdir backup && cd backup
docker run --rm \
  -e VOLUME_NAME=${VOLUME_NAME} -e VOLUME_MOUNT_PATH=${VOLUME_MOUNT_PATH} \
  -v $(pwd):/backup -v ${VOLUME_NAME}:${VOLUME_MOUNT_PATH} \
  -it debian:bullseye bash
tar -cvf /backup/backup.${VOLUME_NAME}.$(date -u +%Y%m%d).tar ${VOLUME_MOUNT_PATH}  # inside docker
exit
scp backup.*.tar ec2-user@node02:/tmp/backup/

# on node02
VOLUME_NAME=...
VOLUME_MOUNT_PATH=...
docker volume create ${VOLUME_NAME}
cd /tmp/backup
docker run --rm \
  -e VOLUME_NAME=${VOLUME_NAME} \
  -v $(pwd):/backup -v ${VOLUME_NAME}:${VOLUME_MOUNT_PATH} \
  -it debian:bullseye bash
cp /backup/backup.${VOLUME_NAME}.*.tar /  # inside docker
tar -xvf /backup.${VOLUME_NAME}.*.tar     # inside docker
exit
```
