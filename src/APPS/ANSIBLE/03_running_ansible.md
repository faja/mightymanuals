## ansible-playbook
usual execution:
```sh
ansible-playbook -i inventory_file 00_first_playbook.yml

# run playbook against single host (or group of hosts)
ansible-playbook -i inventory_file 00_first_playbook.yml -l "${HOST_SELECTION_STRING}"
  # see inventory docs for selecting hosts
  # -l --limit

# run playbook against localhost
ansible-playbook -i 'localhost,' playbook1.yml

# check syntax
ansible-playbook --syntax-check ${PLAYBOOK_FILE}

# dry-run options: list and check
ansible-playbook --list-tasks ${PLAYBOOK_FILE} # to nicely list all tasks in playbook
ansible-playbook --list-hosts ${PLAYBOOK_FILE} # to nicely list all hosts playbook is going to run agains
  # can be used to check if our host_selection_string is correct

ansible-playbook --check ${PLAYBOOK_FILE}        # dry-run
ansible-playbook --check --diff ${PLAYBOOK_FILE} # dry-run, and diff files

# run part of the playbook
--step          - allows to selectively skip a tasks
--start-at-task - allows to start the playbook at specified task
--tags          - run only tasks with specified tags
--skip-tags     - skip specified tags
```

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

# local run
ansible localhost -i 'localhost,' -m setup -e 'ansible_connection=local'
ansible localhost -i 'localhost,' -m setup -c local

##
# to simply test if the "whole" config and connectivity works run
```sh
ansible --list  ${GROUP}|all
ansible -m ping ${GROUP}|all

# to gather/test facts from a single machine
ansible -m ansible.builtin.setup ${MACHINE_NAME}

# if something is wrong with a single machine
ansible -m ping -vvvv ${MACHINE_NAME}
```

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
