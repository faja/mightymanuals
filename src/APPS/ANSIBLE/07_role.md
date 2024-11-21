

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

==============================
=== II.   INSIDE_yml_FILES ===
==============================

tasks/main.yml:
---
- name: ...
  command: ...

- name: ...
  command: ...

- name: create nginx config
  template: ...
  notify: restart nginx

handlers/main.yml:
---
- name: restart nginx
  service: name=nginx state=restarted




a nasz glowny playbook wyglada tak:
---
- hosts: all
  roles:
    - role1
    - role2

=====================
=== III.  INCLUDE ===
=====================

common zachowaniem jest by w mail.yml byly tylko include statements
a caly kod byl w oddzielnych plikach

tasks/main.yml
  ---
  - include: php.yml
  - include: extensions.yml

tasks/php.yml
  ---
  ...<some_code>...

tasks/extensions.yml
  ---
  ...<some_code>...

==========================================
=== IV. DEPENDENCIES_AND_WRAPPER_ROLES ===
==========================================
w meta/main.yml mozemy zdefiniowac nasze dependecies, przez co
wszystkie beda zinkludowane i uruchomione automatycznie przed nasza rola
meta/main.yml
  dependencies:
    - role1
    - someother.role
    - third.role42


w dependencies mozna rowniez, zdefiniowac zmienne, przez co mozna
fajnie tworzyc takie WRAPPERS_ROLES
  dependencies:
    - role: role1
      some_variable: value
      some_variable2: value2
