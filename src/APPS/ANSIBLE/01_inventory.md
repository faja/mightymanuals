---

[inventory official docs](https://docs.ansible.com/ansible/latest/inventory_guide/index.html)

```yaml
---
# basics {{{ ------------------------------------------------------------------#
# by default all hosts belong to group `all`

# there is second "special" group `ungrouped`
ungrouped:
  hosts:
    192.168.59.101:
    192.168.59.102: # this guy however will not be part of `ungrouped` because it belongs to other group
    192.168.59.103:

web:
  hosts:
    192.168.59.102:

prod:
  hosts:
    192.168.59.102:

xxx:
  children:
    web:
# }}} -------------------------------------------------------------------------#

# range of hosts {{{ ----------------------------------------------------------#
oh_wow_a_ragne:
  hosts:
    www[01:02].example.com:
# }}} -------------------------------------------------------------------------#

# variables {{{ ---------------------------------------------------------------#
# "connection" variables are recommended to use here
# however, "variables" variables in inventory file are not recommended
# please use `host_vars` and `group_vars`
vms:
  hosts:
    vm01:
      ansible_host: 192.168.59.101
      http_port: 80 # host level variable
    vm02:
      ansible_host: 192.168.59.102
    vm03:
      ansible_host: 192.168.59.102
  vars: # group level variables
    ansible_user: my_server_user
# }}} -------------------------------------------------------------------------#
```

- to test the inventroy
    - `ansible-inventory -i inventory.yaml --list`
    - `ansible --list -i inventory.yaml all`
    - `ansible --list -i inventory.yaml ${GROUP_NAME}`

- specify inventory dir or file in `ansible.cfg`
    ```
    [defaults]
    inventory=./inventory.yaml ; comma seperate list
    ```

- selecting hosts,
    - `all` - all hosts
    - `*.example.com` - wildcard
    - `web[5:10]` - range of numbered servers
    - `~web\d\.example\.com` - regular expression
    - `dev:staging`- OR
    - `staging:&database` - AND
    - `dev:!queue` - NOT

    we can use above in playbook `- hosts:` and also on command line with option `--limit`, eg:
    ```sh
    ansible-playbook -l 'staging:&database' playbook.yml
    ```

