- [all config options official docs](https://docs.ansible.com/ansible/latest/reference_appendices/config.html)
- or you can run `ansible-config list | less` and search for an option
- config file is searched in the following order:
    - `ANSIBLE_CONFIG` environment variable if set
    - `ansible.cfg` in the current directory
    - `~/.ansible.cfg`
    - `/etc/ansible/ansible.cfg`

- example
    ```toml
    [defaults]
    nocows = true
    inventory = ./inventory.yaml
    stdout_callback = yaml

    callbacks_enabled=ansible.posix.profile_tasks
    #callbacks_enabled=ansible.posix.profile_tasks,community.general.log_plays

    # gathering = smart # worth considering, default: implicit
    # forks = 100       # worth considering, default: 5
    # pipelining = true # worth considering, default: false


    ## connection related, custom user, port etc...
    # remote_port = 22345
    # remote_user = dedicateduser
    # private_key_file = /path/to/id_rsa
    # host_key_checking = false # nice for vagran/docker env, or ec2


    # roles_path = galaxy_roles:roles


    ## privilege_escalation - quite interesting section, but I'd leave it default
    # [privilege_escalation]
    # become = true
    # become_user = admin
    # become_ask_pass = true


    ## ssh_connection
    # [ssh_connection]
    # ssh_args = -o ForwardAgent=yes
    ```


- inventory cache - useful when using dynamic inventory
    ```toml
    [inventory]
    # uses /tmp/ansible_fact_cache/ dir
    cache = true
    cache_plugin = jsonfile
    cache_timeout = 3600 # 1h
    ```
