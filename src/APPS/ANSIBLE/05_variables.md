---

- [variables declaration and precedence](#variables-declaration-locations-and-precedence-order)
- [built-in variables](#built-in-variables)
- [facts](#facts)
- [include_vars module](#include_vars-module)

---

### variables declaration locations and precedence order

<details><summary>01. ROLE DEFAULTS</summary>

- variables defined in `${role_name}/defaults/main.yaml`
</details>

<details><summary>02. INVENTORY VARIABLES</summary>

- variables specified in inventory file
- host related has higher precedence than group
    ```ini
    # host related
    hostname foo=bar

    # group related
    [group1]
    hostname

    [group1:vars]
    foo2=bar2
    ```
</details>

<details><summary>03. INVENTORY GROUP VARIABLES </summary>

- `inventory/group_vars/group_name.yml`
- NOTE! host level variables (even in inventory file) have higher precedence that group
</details>

<details><summary>04. INVENTORY HOST VARIABLES </summary>

- `inventory/host_vars/hostname.yml`
</details>

<details><summary>05. PLAYBOOK GROUP VARIABLES </summary>

- same as `INVENTORY GROUP VARIABLES`, but group_vars directory is at the same level as playbook
- NOTE! host level variables (even in inventory file) have higher precedence that group
    ```sh
    playbookdir/playbook.yaml
    playbookdir/group_vars/groupname.yaml
    ```
</details>

<details><summary>06. PLAYBOOK HOST VARIABLES </summary>

- same as `INVENTORY HOST VARIABLES`, but host_vars directory is at the same level as playbook
    ```sh
    playbookdir/playbook.yaml
    playbookdir/host_vars/groupname.yaml
    ```
</details>

<details><summary>07. HOST FACTS </summary>

- variables gathered by `fact` system
- see: 03_facts TODO!
</details>

<details><summary>08. REGISTERED VARIABLES </summary>

- registered by `register` keyword
    ```yaml
    tasks:
      - stat: path=/etc/hosts
        register: hosts_info
      - debug: var=hosts_info
    ```
</details>

<details><summary>09. SET_FACTS </summary>

- `set_fact` is like another task, at task definition level, eg:
    ```yaml
    tasks:
      - set_fact:
          foo: foo_from_set_fact
      - debug: var=foo
    ```
</details>


<details><summary>10. PLAYBOOK VARIABLES </summary>

- variables defined in playbook file
    ```yaml
    - hosts: all
      vars:
        foo: bar_from_playbook_level
    ```
</details>

<details><summary>11. PLAYBOOK VARS_PROMP </summary>

- variables prompted to define while playbook is running

    ```yaml
    - hosts: all
      vars:
        foo: bar
      vars_prompt:
        - name: user_password
          prompt: "Please enter the password"
          private: yes
    ```
</details>

<details><summary>12. PLAYBOOK VARS_FILES </summary>

- at the playbook level we can define vars_file, which can contain variables
    ```yaml
    - hosts: all
      vars_files:
        - file1.yaml
        - "{{ ansible_os_family }}.yaml"
    ```

- trick with asking and setting a default as well:
    ```yaml
    - hosts: all
      vars_prompt:
        - name: include_file
          prompt: Which file should we include?
      vars_files:
        - ["{{ include_file }}.yml", "default_user.yml"]
    ```
    then if you specify something and it doesn't exist -> default_user.yml will be included instead
</details>

<details><summary>13. ROLE VARIABLES </summary>

- variables specified at the ROLE level
    ```yaml
    - hosts: all
      roles:
        - role: some.role
          variable1: value1
          variable2: value2
    ```
</details>

<details><summary>14. BLOCK VARIABLES </summary>

- variables specified at the BLOCK level
    ```yaml
    - hosts: all
      tasks:
        - block:
          - debug: var=foo
          - debug: msg="foo = {{ foo }}"
          vars:
            foo: bar_from_block_level
    ```
</details>

<details><summary>15. TASK VARIABLES </summary>

- variable set at task level, eg:
    ```yaml
    tasks:
      - debug: var=foo
        vars:
          foo: bar_from_task_level
    ```
</details>

<details><summary>16. EXTRA VARIABLES (cmd line -e)</summary>

- variables defined at the cmd line level by `-e` option
    ```sh
    ansible-playbook playbookname.yml -e 'your_name=Fred'
    ```
- note it can be passed as a FILENAME with `@` notation
    ```sh
    ansible-playbook playbookname.yaml -e @my_custom_variables.yaml
    ```
</details>


### built-in variables
- `{{ hostvars }}` - a massive dict that contain all hostvars for all hosts, eg usage:
    ```yaml
    {{ hostvars['db.example.com'].ansible_eth1.ipv4.address }}
    ```
- `{{ inventory_hostname }}` - current host name from the inventory
- `{{ inventory_hostname_short }}` - current host name from the inventory without domain name
- `{{ group_names }}` - list of groups current host belongs to
- `{{ groups }}` - dict of all groups, example usage:
    ```yaml
    {% for host in groups.web %}
    server {{ hostvars[host].inventory_hostname }} \
      {{ hostvars[host].ansible_default_ipv4.address }}:80
    {% endfor %}
    ```
- `{{ groups['group_name'] }}` - list of machines which belongs to that `group_name`
- `{{ ansible_check_mode}}`
- `{{ ansible_version }}`

[ALL variables](https://docs.ansible.com/ansible/latest/reference_appendices/special_variables.html)


### facts

- all ansible facts starts with `ansible_` prefix
    - automatic ones with `ansible_facts.`
    - manual ones with `ansible_local.`
- get all facts for a host
    ```sh
    ansible -m setup ${HOSTNAME}
    ```
- to disable facts:
    ```yaml
    ---
    - hosts: all
      gather_facts: false
    ```
- to trigger gathering manually
    ```yaml
    - name: Deploy mezzanie
      hosts: web
      gather_facts: false

      tasks:
        - name: ...

        - name: gather facts
          setup:

        - name: ...
    ```
- actually any module can return facts that will be registerd with `ansible_facts`
it just needs to return output that contains key `ansible_facts`, for example
`service_facts` module does it:
    ```yaml
    - name: get services facts
      service_facts:

    - debug: var=ansible_facts['services']['sshd.service']
    ```

##### custom facts
Custom facts are read from `/etc/ansible/facts.d/*.fact` and exposed with
`ansible_local` directory, eg:

- /etc/ansible/facts.d/users.fact
    ```ini
    [mc]
    colors = true
    ```
- would generate
    ```json
    "ansible_local": {
        "users": {
            "mc": {
                "colors": "true"
            }
        }
    }
    ```
- hence available as `{{ ansible_local.users.mc.colors }}`
- local/custom `.fact` file can be in format:
    - INI
    - JSON
    - or it can be an executable that takes no arguments and outputs JSON to stdout

#### `set_fact` module
```yaml
- name: set nginx state
  when: ansible_facts.services.nginx.state is defined
  set_fact:
    nginx_state: "{{ ansible_facts.services.nginx.state }}"
```

### include_vars module

```yaml
---
- name: gather os specific variables
  include_vars: "{{ item }}"
  with_first_found:
    - files:
        - "{{ ansible_distribution|lower }}-{{ ansible_distribution_release|lower }}.yml"
        - "{{ ansible_distribution|lower }}.yml"
        - os-defaults.yml
      paths:
        - ../vars
```
