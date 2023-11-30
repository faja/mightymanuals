If we have a map type variable, and we wanna pass it as an env variable `TF_VAR_`
we need to use `json`, eg:
```sh
TF_VAR_some_map_var='{"key1":"value1","key2":"value2"}'
```

---

```
{{#include main.tf}}
```
