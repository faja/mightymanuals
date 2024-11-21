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
