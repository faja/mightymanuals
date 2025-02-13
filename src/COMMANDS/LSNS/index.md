---

provides information about ALL the namespaces in the system

```sh
lsns --output-all | grep -e NS -e net  # get network namespaces
# first column `NS` can be mapped with the output of
# ls -la /proc/<pid>/ns
```
