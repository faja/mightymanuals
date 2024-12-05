---

MODULES:

- [apt](#apt)
- [assert](#assert)
- [authorized_key](#authorized_key)
- [command](#command)
- [debug](#debug)
- [fail](#fail)
- [file](#file)
- [git](#git)
- [meta](#meta)
- [template](#template)
- [wait_for](#wait_for)

---

### apt

[official docs](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/apt_module.html)

```yaml
- name: ...
  become: true
  apt:
    update_cache: true
    cache_valid_time: 900 # 15mins
    pkg:
      - curl
      - ...
      - ...
```

### assert
[official docs](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/assert_module.html)

The `assert` module will fail with an error if a specified condition is not met

Please note code in an assert statement is Jinja not Python.

- single
    ```yaml
    - name: ...
      ansible.builtin.assert:
        that: single_statement_that_returns_bool
    ```

- list
    ```yaml
    - name: ...
      ansible.builtin.assert:
        that:
          - single_statement_that_returns_bool
          - another_that returns_bool
          # both must be TURE
    ```

- common case to check output from previous task
    ```yaml
    - name: stat  /boot/grub
      stat:
        path: /boot/grub
      register: st

    - name: assert that /boot/grub is a directory
      assert:
        that: st.stat.isdir
    ```



### authorized_key
todo

### command

[official docs](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/command_module.html)

- simple
    ```yaml
    - name: ...
      become: true
      ansible.builtin.command:
        cmd: /usr/bin/make_database.sh db_user db_name
        creates: /path/to/database
    ```

- more complex
    ```yaml
    - name: ...
      become: true
      ansible.builtin.command:
        argv:
          - /path/to/binary
          - -v
          - --debug
          - --longopt
          - value for longopt
          - --other-longopt=value for other longopt
          - positional
        creates: /path/to/database
    ```

### debug
[official docs](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/debug_module.html)

- short version - for quick debug purposes
    ```yaml
    - debug: var=myvarname_i_wanna_debug
    ```

- long
    ```yaml
    - name: Show a debug message
      debug:
        msg: "The debug module will print a message: neat, eh?"
    ```

### fail
[official docs](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/fail_module.html)

- causes ansible to fail the run, common use case:
    ```yaml
    - name: some task, that fail but we set it to ignore errors
      ...
      register: result
      failed_when: false # or even ignore_errors

    - debug: var=result

    - fail:
    ```

- fail with message:
    ```yaml
    - name: Example using fail and when together
      ansible.builtin.fail:
        msg: The system may not be provisioned according to the CMDB status.
      when: cmdb_status != "to-be-staged"
    ```

### file
[official docs](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/file_module.html)

- standard file
    ```yaml
    - name: ...
      become: true
      ansible.builtin.file:
        path: /etc/foo.conf
        owner: foo
        group: foo
        mode: '0644'
    ```

- directory
    ```yaml
    - name: ensure config path exists
      become: true
      ansible.builtin.file:
        path: "{{ conf_path }}"
        state: directory
        mode: '0755'
    ```

- symlink
    ```yaml
    - name: ...
      become: true
      ansible.builtin.file:
        src: ...
        dest: ...
        state: link
        mode: '0777'
    ```

- remove
    ```yaml
    - name: ...
      become: true
      ansible.builtin.file:
        paht: /etc/nginx/conf.d/default
        state: absent
    ```

### git
[official docs](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/git_module.html)

```yaml
- name: ...
  git:
    repo: "{{ repo_url }}"
    dest: "{{ proj_path }}"
    version: master
    accept_hostkey: true
```

### meta
[official docs](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/meta_module.html)

meta module is used to perform various actions playbook related, like flush handlers,
end playbook, etc..
```yaml
- name: ...
  meta: flush_handlers
```

actions:
```
- flush_handlers
- refresh_inventory
- end_host
- end_play
```

### template
[official docs](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html)

- basic
    ```yaml
    - name: ...
      template:
        src: ...
        dest: ...
        mode: '0640'
    ```

- validate sudoers
    ```yaml
    - name: ...
      template:
        ...
        validdate: 'bash -c "cat /etc/sudoers /etc/sudoers.d* %s | visudo -cf-"'
    ```

### wait_for
[official docs](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/wait_for_module.html)
- simple SLEEP
    ```yaml
    - name: Sleep for 300 seconds and continue with play
      ansible.builtin.wait_for:
        timeout: 300
      delegate_to: localhost
    ```
- check network connection
    ```yaml
    - name: ...
      wait_for:
        host: ...
        port: 22
        search_regex: OpenSSH
        delay: 60
    ```
