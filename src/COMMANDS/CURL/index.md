---

```sh
curl --cacert <file> --cert <file> --key <file>
curl -qsS -L
  # -q --disable, do not check for curl config file
  # -s --silent, do not show progress meter or error messages
  # -S --show-error, makes curl show an error if it fails
  # -L --location, follow redirecs

curl --fail|--fail-with-body
  # good for scripting, it exits with 22 if responce code > 400
```
