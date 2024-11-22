---
task OPTIONS/PROPERTIES/CLAUSES:

- [become](#become-become_user)
- [become_user](#become-and-become_user)
- [changed_when](#changed_when)
- [environment](#environment)
- [failed_when](#failed_when)
- [ignore_errors](#ignore_errors)
- [notify](#notify)
- [register](#register)
- [remote_user](#remote_user)
- [tags](#tags)
- [when](#when)

---

### `become` and `become_user`
```yaml
- name: ...
  become: true
  become_user: postgres
  ...
```

### `changed_when`
```yaml
- name: ...
  changed_when: condition_that_evaluates_to_BOOLEAN
```

### `environment`
passes environment variable to task
```yaml
- name: ...
  script: scripts/setsite.py
  environment:
    PATH: ...
    XXX_YYY: ...
```

### `failed_when`
```yaml
- name: ...
  failed_when: condition_that_evaluates_to_BOOLEAN
```

### `ignore_errors`
by default, if tasks fails, ansible ends its run,
with, this set to true, it will continue
```yaml
- name: run myprog
  command: /opt/myprog
  register: result
  ignore_errors: true

- debug: var=result
```

### `notify`
todo

### `register`
allows to register output of a task
```yaml
- name: capture output of whoami command
  command: whoami
  register: login

- debug: var=login
```

### `remote_user`
equivalent of `ansible_user` from inventory - it tells which user ot use to ssh

### `tags`
add a tag to task (or role, block, play)
```yaml
- name: ...
  tags:
```

### `when`
allows execute task conditionally
```yaml
- name: ...
  when: some_condition_that_must_return_boolean
  my_module: ...
```
