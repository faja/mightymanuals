---

Callback plugins:
- stdout
- notification
- aggregate

---

# stdout plugins
- defines how ansible output is formated
- only - single stdout plugin can  b e active at a time
- `ansible-doc -t callback -l`
- `ansible.cfg`
    ```ini
    [default]
    stdout_callback = yaml
    # cool one: debug, oneline
    # "default" is the default

    [callback_profile_tasks]
    task_output_limit = 20 # default, set to `all` for unlimited
    summary_only = false   # default
    ```
- ...

# notification and aggregate
## profile_tasks
- displays how much time tasks took
- `ansible-doc -t callback profile_tasks`
- `ansible.cfg`
    ```ini
    [default]
    callbacks_enabled=ansible.posix.profile_tasks
    ```

## log_plays
- logs play output info to a file, one per each host
- `ansible-doc -t callback log_plays`
- `ansible.cfg`
    ```ini
    [default]
    callbacks_enabled=community.general.log_plays

    [callback_log_plays]
    log_folder = /var/log/ansible/hosts # default
    ```
