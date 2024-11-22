---

lookups allow to fetch some data/variable from various places, like files,
redis, command, etc...

pretty neat

IMOIRTANT! all lookups executes on CONTROL MACHINE not the remote host

---

- [custom lookups](#custom-lookups)

---

```sh
ansible-doc -t lookup -l
ansible-doc -t lookup ${LOOKUP_NAME}
```

LOOKUPS:

- [env](#env)
- [file](#file)
- [password](#password)
- [pipe](#pipe)
- [template](#template)

### env
[docs](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/env_lookup.html)

read the value of environment variable

```yaml
"{{ lookup('env', 'SHELL') }}"
```


### file
[docs](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/file_lookup.html)

```yaml
key: "{{ lookup('file', item) }}"
```

### password
[docs](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/password_lookup.html)

### pipe
[docs](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/pipe_lookup.html)

read  output from a command

```yaml
"{{ lookup('pipe', 'some_command') }}"
```

### template
[docs](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_lookup.html)

read a template and outputs it's rendered content

```yaml
"{{ lookup('template', 'message.j2') }}"
```

---

# custom lookups
- you can create custom lookups
- ansible will look for custom lookups in
  - `lookup_plugins` in your playbook directory
  - `~/.ansible/plugins/lookup`
  - `/usr/share/ansible/plugins/lookup`
  - location specified by `ANSIBLE_LOOKUP_PLUGINS`
