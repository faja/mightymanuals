---

- quick partition growfs
```sh
# resize underlying block device first, then
lsblk                      # to find disk and partition number
growpart nvme3n1 1         # growpart ${DISK} ${PARTITION}
xfs_growfs /var/lib/docker # xfs_growfs ${MOUNT}
```
