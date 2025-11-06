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

- tldr

    ```sh
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

- a real life example

    ```sh
    # node02
    docker pull amsdard.io/portus-sync:0.3.3
    docker pull opensuse/portus:2.4.3
    docker pull postgres:11.22-alpine
    docker pull redis:latest
    docker pull registry:2.7.1

    mkdir /tmp/registry
    VOLUME_NAME=registry_dbdata
    docker volume create ${VOLUME_NAME}

    # node01
    rsync -avzH -e ssh --stats --progress /var/lib/docker-compose/registry root@172.30.91.136:/var/lib/docker-compose
    # edit volumes:
    #   - add "prefix" to the name in `volumes` section: registry_dbdata
    #   - add "external: true"
    #   - rename it's usage in `services` section - if needed

    # terraform alb point to node02

    # node01
    mkdir /tmp/registry
    docker stop registry_db_1
    docker stop registry_portus-sync_1
    docker stop registry_portus_1
    docker stop registry_portus-background_1
    docker stop registry_redis_1
    docker stop registry_registry_1

    VOLUME_NAME=registry_dbdata
    VOLUME_MOUNT_PATH=/var/lib/postgresql/data
    cd /tmp/registry
    docker run --rm \
      -e VOLUME_NAME=${VOLUME_NAME} -e VOLUME_MOUNT_PATH=${VOLUME_MOUNT_PATH} \
      -v $(pwd):/backup -v ${VOLUME_NAME}:${VOLUME_MOUNT_PATH} \
      -it debian:bullseye bash
    tar -cvf /backup/backup.${VOLUME_NAME}.$(date -u +%Y%m%d).tar ${VOLUME_MOUNT_PATH}  # inside docker
    exit

    scp backup.*.tar root@172.30.91.136:/tmp/registry/

    # node02
    VOLUME_NAME=registry_dbdata
    VOLUME_MOUNT_PATH=/var/lib/postgresql/data
    cd /tmp/registry
    docker run --rm \
      -e VOLUME_NAME=${VOLUME_NAME} \
      -v $(pwd):/backup -v ${VOLUME_NAME}:${VOLUME_MOUNT_PATH} \
      -it debian:bullseye bash
    cp /backup/backup.${VOLUME_NAME}.*.tar /  # inside docker
    tar -xvf /backup.${VOLUME_NAME}.*.tar     # inside docker
    ls -la ${VOLUME_MOUNT_PATH}               # inside docker
    exit

    cd /var/lib/docker-compose/registry
    docker compose up -d
    ```

### how to move docker volume to host volume (same host)
```sh
VOLUME_NAME=...
HOST_PATH=...
docker run --rm -it -v ${VOLUME_NAME}:/data -v ${HOST_PATH}:${HOST_PATH}:rw debian:bullseye bash
cp -rp /data/* ${HOST_PATH}/ # inside docker
exit
```

