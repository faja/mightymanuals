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

## loop_control.loop_var
If we want to use other name than `item` in our loop, for example we have to nested loops and we want to avoid clashing, we can use `loop_control.loop_var`

```yaml
with_items:
  - name: ruby_19
    chruby: system
  - name: ruby_22
    chruby: ruby-2.2
loop_control:
  loop_var: other_item_name
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
