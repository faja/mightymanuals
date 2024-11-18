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

    # gathering = smart # worth considering, default: implicit
    # forks = 100       # worth considering, default: 5
    # pipelining = true # worth considering, default: false

    # host_key_checking = false # nice for vagran/docker env

    # remote_port = 22345
    # remote_user = dedicateduser
    # private_key_file = /path/to/id_rsa

    ## privilege_escalation - quite interesting section, but I'd leave it default
    # [privilege_escalation]
    # become = true
    # become_user = admin
    # become_ask_pass = true
    ```
