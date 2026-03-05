---

```sh
ps -eF            # show all processes
ps -eFL           # include threads in the output
ps -eF --forest   # show "tree" like output
```

nice 1liners:
```sh
# print long command line by line
ps -p 3138 -o command --no-header | tr '[:space:]' '\n'
```
