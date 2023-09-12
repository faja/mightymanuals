to simply test if the "whole" config and connectivity works run
```sh
ansible --list  ${GROUP}|all
ansible -m ping ${GROUP}|all

# to gather/test facts from a single machine
ansible -m ansible.builtin.setup ${MACHINE_NAME}
```

## ansible-playbook
usual execution:
```
ansible-playbook -i inventory_file 00_first_playbook.yml
```
local run:
```
ansible-playbook -i 'localhost,' playbook1.yml
ansible localhost -i 'localhost,' -m setup -e 'ansible_connection=local'
ansible localhost -i 'localhost,' -m setup -c local
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
```
ansible testserver -i inventory -m ping
ansible testserver -i inventory -m command -a uptime
ansible testserver -i inventory -b -m service -a "name=nginx state=restarted"
```
