---

- a playbook is a list of plays
- a play is a list of tasks

### playbook structure

```yaml
---
- name: my first playbook
  hosts: webservers
  become: ture
  vars: ...
  gather_facts: true

  handlers:
    - name: ...

  tasks:
    - name: ...
```

### playbook config properties
- `name` - description of a playbook
- `hosts` - hosts string
- `become` - when set to true, ansible will become `become_user` (default `root`)
- `vars` - playbook scope variables
- `gather_facts` - to gather facts or not
