

### role reference in playbook

```yaml
- name: ...
  roles:
    - role: name_of_the_role
      var1: value
      var2: value
    - role: name_of_the_other_role
      var3: value
    - role: role_with_no_vars_being_passed
```

### roles_path
setting roles path in ansible.cfg

```toml
[defaults]
roles_path = galaxy_roles:roles
```

### basic structure of a role
to create a basic structure run:
```sh
ansible-galaxy role init ${NAME_OF_THE_ROLE}
```

```
.
├── defaults/
│   └── main.yml
├── files/
│   └── some_file_with_no_templating.py
├── handlers/
│   └── main.yml
├── meta/
│   └── main.yml
├── README.md
├── tasks/
│   └── main.yml
├── templates/
│   └── test.conf.j2
├── tests
│   ├── inventory
│   └── test.yml
└── vars
    └── main.yml
```

### include_tasks
In roles, a common approach is to have `tasks/main.yaml` that includes other
files:
```yaml
---
- include_tasks: php.yaml
- include_tasks: extensions.yaml
```
just bear in mind `include_tasks` is just another module ~> [docs](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/include_tasks_module.html)


### dependecies and wrapper roles
In `meta/main.yaml` you can specify list of dependencies,
that will be included automagically,



```yaml
---
dependencies:
  - role1
  - someother.role
  - third.role42
```

you can also provide some variables for them, such pattern is called
**WRAPPER ROLES**:

```yaml
---
dependencies:
  - role: common
    vars:
      some_parameter: 3
  - role: apache
    vars:
      apache_port: 80
  - role: postgres
    vars:
      dbname: blarg
      other_parameter: 12
```
