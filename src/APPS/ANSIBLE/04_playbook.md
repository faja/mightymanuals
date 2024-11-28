---

- a playbook is a list of plays
- a play is a list of tasks

### playbook structure

```yaml
---
- name: my first playbook
  hosts: webservers
  become: ture
  gather_facts: true
  vars: ...
  vars_files: ...
  serial: ...
  max_fail_percentage: ...
  strategy: ...

  handlers:
    - name: ...

  # with tasks
  tasks:
    - name: ...

  # with roles
  roles:
    - role: ...

  # tasks to execute first
  pre_tasks:
    - name:

  # tasks to execute at the end
  post_tasks:
    - name:
```

### playbook config properties
- `name` - description of a playbook
- `hosts` - hosts string
- `become` - when set to true, ansible will become `become_user` (default `root`)
- `vars` - playbook scope variables
- `vars_files` - list of playbook scoped variable files
- `gather_facts` - to gather facts or not
- `serial` - allows to run specific number of hosts at the same time
    ```yaml
    serial: 1    # one at a time
    serial: 50%  # half now, half after
    serial:      # start with 1 host, then go for 30%
      - 1
      - 30%
    ```
- `max_fail_percentage` - allows to stop playbook if there are errors, setting
    to `0` fails playbook if any hosts fail
- `strategy` - by default, playbook runs task by task on all machines, it starts
    with 1st task, waits for all the hosts, then run next one, this default behaviour/strategy
    is called `linear`, to NOT wait but just change stratrgy to `free`, see
    [docs](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_strategies.html#selecting-a-strategy)
    for details
