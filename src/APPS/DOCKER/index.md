- [compose](./COMPOSE/index.md)

---

```sh
docker container inspect xyz | jq '.[] | .Config.Labels'
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
