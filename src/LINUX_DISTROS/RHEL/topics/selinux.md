---

### `/etc/selinux/config`
```yaml
# SELINUX= can take one of these three values:
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.

# SELINUXTYPE= can take one of these three values:
#     targeted - Targeted processes are protected,
#     minimum - Modification of targeted policy. Only selected processes are protected.
#     mls - Multi Level Security protection.

# eg to disable
SELINUX=disabled
SELINUXTYPE=targeted
```

### commands
```sh
/usr/sbin/getenforce    # check what mode is currently set
/usr/sbin/setenforce 0  # set selinux to PERMISSIVE
/usr/sbin/setenforce 1  # set selinux to ENFORCING
```
