#

```sh
# `nohup` - do not kill the process if shell exists
# redirect stdout and stderr to a file
# & - run in the background
nohup ./cli --some-option > /tmp/output.txt 2>&1 &
```
