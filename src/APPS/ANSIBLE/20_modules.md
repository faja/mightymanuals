---

MODULES:

- [apt](#apt)
- [debug](#debug)

---

### apt

```yaml
- name: ...
  become: true
  apt:
    update_cache: true
    cache_valid_time: 900 # 15mins
    pkg:
      - curl
      - ...
      - ...
```

### debug

- short version - for quick debug purposes
    ```yaml
    - debug: var=myvarname_i_wanna_debug
    ```

- long
    ```yaml
    - name: Show a debug message
      debug:
        msg: "The debug module will print a message: neat, eh?"
    ```
