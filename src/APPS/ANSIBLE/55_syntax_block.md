---
Allows to groupp multiple tasks in one logical block, and apply task level
keyword to all of them.

```yaml
- block:
  - name: task1
    ...
  - name: task2
    ...
  - name: task3
    ...

  become: yes
  when: ...

  # optional try/catch thingy
  rescue:
    - name: rescue task1 will be executed if any of the normal ones fail
      ...
    - name: rescue task2 will be executed if any of the normal ones fail
      ...

  always:
    - name: will be always executed (even if error occurs in rescue clause)
      ...
```
