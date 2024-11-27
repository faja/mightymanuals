# Looping
## with_items
```yaml
- name: ensure all pakages are installed
  apt:
    pkg: "{{ item }}"
    state: present
  with_items:
    - pkg1
    - pkg2
```

other `with_` lookup plugins:
```
with_items            - predefined list of items
with_lines            - execute a command and iterates over output lines
with_fileglob
with_first_found
with_dictflattened
with_indexed_items
with_nested
with_random_choice
with_sequence
with_subelements
with_together
with_inventory_hostnames
```

## loop_control.loop_var and index_var
If we want to use other name than `item` in our loop, for example we have to nested loops and we want to avoid clashing, we can use `loop_control.loop_var`
Also, just FYI, `loop` keyword is equivalent to `with_items`

```yaml
tasks:
  - name: test task
    ansible.builtin.debug:
      msg: "index: {{ index }}, item: {{ i }}"
    loop:
      - xxx
      - yyy
      - zzz
    loop_control:
      loop_var: i
      index_var: index
```

## loop_control.label
when we run the task, ansible will print the whole "item" for each loop, if our item is complex hash, it will print everything to the display, which kind of ugly,
to print only one thing we can use `loop_control.label`
```yaml
with_items:
  - name: ruby_19
    chruby: system
  - name: ruby_22
    chruby: ruby-2.2
loop_control:
  label: "{{ item.name }}"
```

## with_dict
```yaml
vars:
  foo:
    bar:
      baz:
        more:
          nesting: ok

tasks:
  - debug: var=item.value.baz.more.nesting
    with_dict: "{{ foo }}"
  - debug: var=item.key
    with_dict: "{{ foo }}"
```
