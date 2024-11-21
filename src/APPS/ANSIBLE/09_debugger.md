---
Use `debugger` keyword to enable (or disable) debugger for specific
`play`/`role`/`block`/`task`.

```
- name: ...
  debugger: always
```

when a task stops in `(debug)` we can do:
```sh
task        # to print task
p task      # ^^ same

task.args   # to print task/module arguments
p task.args # ^^ same

task_vars   # to print task variables
p task_vars # ^^ same

task.args[key] = value           # set new task/module argument, eg:
task.args["msg"] = "ok, new msg"

task_vars[key] = value           # set new task/module argument, eg:
task_vars["my_custom_variable"] = "new_value"

r    # to re-execute the task
c    # to continue
q    # to quit
```
