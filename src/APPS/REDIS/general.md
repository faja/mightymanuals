---

- [general](#general)
- [redis-cli](#redis-cli)

---

- start server and listen on specific interface/port
    ```sh
    redis-server --bind *         --port 6379  # default
    redis-server --bind 127.0.0.1 --port 7777
    ```
- starting server with NO PROTECTED-MODE
    ```sh
    redis-server --protected-mode no
    ```
- test/debug crash
  ```sh
  # note, `enable-debug-command local` (or yes) must be in the config
  redis-cli DEBUG SEGFAULT
  ```

# redis-cli

```sh
# authentication
redis-cli -a ${PASSWORD} --no-auth-warning
# or
redis-cli
  > AUTH ${PASSWORD}

# INFO
# various details about "SECTIONs"
> INFO replication
> INFO persistence
```
