---
- `when` - allows execute task conditionally
    ```yaml
    - name: ...
      when: some_condition_that_must_return_boolean
      my_module: ...
    ```

- `register` - allows to register output of a task
    ```yaml
    - name: capture output of whoami command
      command: whoami
      register: login

    - debug: var=login
    ```

- `ignore_errors` - by default, if tasks fails, ansible ends its run,
with, this set to true, it will continue
    ```yaml
    - name: run myprog
      command: /opt/myprog
      register: result
      ignore_errors: true

    - debug: var=result
    ```

- `environment` - passes environment variable to task
    ```yaml
    - name: ...
      script: scripts/setsite.py
      environment:
        PATH: ...
        XXX_YYY: ...
    ```

- `become` and `become_user`
    ```yaml
    - name: ...
      become: true
      become_user: postgres
      ...
    ```

- `notify`

- `remote_user`
equivalent of `ansible_user` from inventory - it tells which user ot use to ssh

- `tags`
add a tag to task (or role, block, play)
    ```yaml
    - name: ...
      tags:
    ```
