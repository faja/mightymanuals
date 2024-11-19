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
