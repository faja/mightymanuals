---

TLDR:
- `include` keywoard is deprecated, please use `(include|import)_(task|role)`
- `include_(task|role)` aka `includes` allow to dynamically includes other tasks
- `import_(task|role)` aka `imports` statically puts content of a different task
    to the current one
- if you don't know which one to pick, you most likely wanna use `include_`

- when we use `include_` task level keywords like loops etc, apply to the `include_`
    itself!
- when we use `import_` task level keywords like loops etc, apply to all tasks
    in the imported file!
- note: `include_` will cause 1 extra task to appear, the include:
    ```yaml
    TASK [${role_name} : include_tasks] ...
    ```
- note: `import_` skips the above, bc, the content is literally copy-pasted


---

example of dynamic includ
```yaml
# instead of
- include_tasks: Redhat.yaml
  when: ansible_os_family == 'Redhat'
- include_tasks: Debian.yaml
  when: ansible_os_family == 'Debian'

# go for
- include_tasks: "{{ ansible_os_family}}.yaml"
```
