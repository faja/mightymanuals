---
[community.sops](https://docs.ansible.com/ansible/latest/collections/community/sops/index.html)

### tldr;
- get a single value from a sops file, second argument - path, is relevant to
  where we are runing `ansible-playbook` from
    ```yaml
    - name: Output secrets to screen (BAD IDEA!)
      ansible.builtin.debug:
        msg: "Content: {{ lookup('community.sops.sops', 'secrets/secrets.yaml', extract='[\"other_key\"]') }}"
    ```

- load variables from a file
    ```yaml
    # create sops file: vars/stuff.sops.yaml in playbook directory, then:

    - name: Include variables of stuff.sops.yaml into 'root' namespace
      community.sops.load_vars:
        file: stuff.sops.yaml
    # then secrets can be used directly eg: {{ alertmanager_slack_api_key }}

    - name: Include variables of stuff.sops.yaml into the 'stuff' prefix
      community.sops.load_vars:
        file: stuff.sops.yaml
        name: stuff
    # then all secrets are in `stuff` namespace and can be used like that:
    # {{ stuff.alertmanager_slack_api_key }}
    ```

- MY WAY to go:
    ```yaml
    # [ROLE] in the role just use standard plaintext variable, define it in `defaults/main.yaml`, eg:
    alertmanager_slack_api_key: plain_text_var_please_override_me

    # [ROLE] use it in a template file like:
    api_url: https://hooks.slack.com/services/{{ alertmanager_slack_api_key }}

    # [PLAYBOOK] then in the playbook use pre_task, load vars via encrypted sops file
    pre_tasks:
      - name: Include variables from secrets.sops.yaml
        community.sops.load_vars:
          file: secrets.sops.yaml

    # [ROLE] pro tip! use extra variable to set `no_log: true` for templates etc...
    - name: Write secret config file
      ansible.builtin.template:
        ...
      no_log: "{{ alertmanager_ansible_no_log }}"
    ```
