to simply test if the "whole" config and connectivity works run
```sh
ansible --list  ${GROUP}|all
ansible -m ping ${GROUP}|all

# to gather/test facts from a single machine
ansible -m ansible.builtin.setup ${MACHINE_NAME}

# if something is wrong with a single machine
ansible -m ping -vvvv ${MACHINE_NAME}
```

## ansible-playbook
usual execution:
```sh
ansible-playbook -i inventory_file 00_first_playbook.yml
ansible-playbook -i inventory_file 00_first_playbook.yml -l "${HOST_SELECTION_STRING}"
  # see inventory docs for selecting hosts
```
local run:
```sh
ansible-playbook -i 'localhost,' playbook1.yml
ansible localhost -i 'localhost,' -m setup -e 'ansible_connection=local'
ansible localhost -i 'localhost,' -m setup -c local
```

interesting
```sh
ansible-playbook --list-tasks ${PLAYBOOK_FILE} # to nicely list all tasks in playbook
```

### flags to ansible-playbook
- `--syntax-check` - check if syntax is valid
- `--list-tasks` - lists tasks which will be executed
- `--list-hosts` - lists hosts on which the playbook will be executed
- `-C` or `--check` - runs in check mode (dry run)
- `--step` - ansible prompt you before executing each task, (y/n/c)
- `-D` or `--diff` - shows diff of changed files
- `--start-at-task` - allows to start the playbook at specified task
- `-t` or `--tags` - run only tasks with specified tags
- `--skip-tags` - skip specified tags


## ansible
```sh
# -b     - become
# -m     - module
# -a     - pass argument to the module
# -vvvv  - debug
ansible testserver -i inventory -m ping
ansible testserver -i inventory -m ping -vvvv
ansible testserver -i inventory -m command -a uptime
ansible testserver -i inventory -a uptime # same as above, be `command` module is a default
ansible testserver -i inventory -b -m service -a "name=nginx state=restarted"
```
## ansible-inventory
```sh
ansible-inventory -i inventory.yaml --graph
ansible-inventory -i inventory.yaml --list
```

## ansible-doc
```sh
ansible-doc --list
ansible-doc ${MODULE_NAME}
```

## validate
```sh
ansible-playbook --syntax-check my-awesome-playbook.yaml
ansible-lint my-awesome-playbook.yaml
yamllint my-awesome-playbook.yaml
ansible-inventory --host my_host -i inventory_file.yaml
```
