---

# localhost
```sh
mkdir ${ANSIBLE_PROJECT} && cd ${ANSIBLE_PROJECT}
touch ansible.cfg
mkdir inventory group_vars host_vars
touch inventory/inventory.yaml
touch group_vars/all.yaml group_vars/group_1.yaml # per group vars
touch host_vars/host_1.yaml host_vars/host_2.yaml  # per host vars
```

```sh
cat <<EOT > ansible.cfg
[defaults]
nocows = true
inventory = ./inventory/inventory.yaml
stdout_callback = yaml
roles_path = ../../roles
gathering = explicit
hash_behaviour = merge # NOTE!
EOT

cat <<EOT > inventory/inventory.yaml
---
ungrouped:
  hosts:
    192.168.59.101:
    192.168.59.102:
    192.168.59.103:
EOT

cat <<EOT > group_vars/all.yaml
---
some_vars_goes_here: yes
EOT

cat <<EOT > host_vars/host_1.yaml
---
some_vars_goes_here: yes
EOT
```

# remote
- `sudoers`, ansible group can do anything, `/etc/sudoers.d/ansible
    ```sh
    %ansible ALL=(ALL) ALL
    ```
