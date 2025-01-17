[https://taskfile.dev/](https://taskfile.dev/)

---

### `Taskfile.yaml`
```yaml
---
version: '3'

# global variables
vars:
  SOME_GLOBAL_VAR: Hello from Taskfile!

tasks:
  default:
    cmds:
      - task --list
  task1:
    desc: ...
    cmds:
      - ...
  task2:
    desc: ...
    cmds:
      - ...

  task3_with_variable:
    desc: ...
    vars:
      GREETING: '{{.GREETING | default "hello default value"}}'
    cmds:
      - echo {{.GREETING}}  # task task3_with_variable GREETING="hello from cli"
    requires:
      vars: [GREETING]
```
