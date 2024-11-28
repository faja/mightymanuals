# handlers

### manually flushing handlers
you can flush handlers with `meta` module
```yaml
- name: install home page
  ...
  notify: restart nginx

- name: restart nginx
  meta: flush_handlers
```
see [meta](./20_modules.md#meta)

### list of handlers
`notify` can be a list!
```yaml
- name: ...
  ...
  notify:
    # handlers will be executed one by one
    - check nginx configuration
    - restart nginx
```

### listen
pretty cool concept, three main features:
- allows you to use "nicer" name, it works like a label
    ```yaml
    handlers:
      - name: restart postfix long handler name
        ...
        listen: restart_postfix # short nice label, no whitespaces

    tasks:
      - name: ...
        notify: restart_postfix
    ```

- use single listen/label for multiple handlers, this is not that useful, as I'd
    prefer to use "list of handlers" instead, but still
    ```yaml
    handlers:
      - name: handler1
        ...
        listen: uber_handler_notification

      - name: handler2
        ...
        listen: uber_handler_notification

    tasks:
      - name: ...
        notify: uber_handler_notification
    ```
- [killer feature] register a listener in one place, then subscribe to it in different
    placethis - works really well cross role,
    ```yaml
    # role 1 `ssl`
    # dummy handler, to avoid errors
    handlers:
      - name: SSL certs changed
        debug:
          msg: SSL changed event triggered
        listen: ssl_certs_changed

    tasks:
      - name: generate ssl certs
        ...
        notify: ssl_certs_changed

    # role 2 `nginx`, `postfix`, whatever
    handlers:
      - name: SSL certs changed
        debug:
          msg: trigger nginx restart due to certs changed
        changed_when: true
        notify:
          - check nginx config
          - restart nginx
        listen: ssl_certs_changed
    ```

### pre- and post-tasks
Just FYI: each `tasks` section executes handlers separately, so if you specify same handler in
`pre_tasks`, `tasks` and `post_tasks` it will be executed three times

