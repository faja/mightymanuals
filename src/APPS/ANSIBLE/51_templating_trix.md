---
- for loop
  ```
  ALLOWED_HOSTS = [{% for domain in domains %}"{{ domain }}",{% endfor %}]
  ```

- if
  ```
  {% if tls_enabled %}
  ...
  {% endif %}
  ```

- join
  ```
  {{ domains | join(", ") }}
  ```

- use `~` to variable concatination between double braces
    ```yaml
    ... {{ server_name ~ '.' ~ domain_name }} ...
    ```

- to access variable with a `-` `.` or `space` use `[ ]` notation
    ```yaml
    result['blabla'].mode
    result.blabla['mode']
    result['service']['sshd.service']
    result['service'][my_service_variable] # variables can be used as well, nice
    ```

- <span style="color:#ff4d94">**HOT!**</span> whitespacing and blocks `{% %}`

    TLDR; use
    ```yaml
    trim_blocks: true   # this is actually the default
    lstrip_blocks: true # by default this is false
    ```

    in general this is the topic on how to deal with whitespaces when using
    block `{% %}` for `for` or `if` statements, lets have a look at the example:

    ```yaml
    line1
      {% if something %}
    line2
      {% end %}
    line3
    ```

    by default this will be rendered like

    ```yaml
    line1
      line2
      line3
    ```

    which is weird, but it happens because we have two spaces before each `{%` block
    (and also a new line after `%}`) - this behaviour is controlled  with two properties:

    - `trim_blocks` - remove a new line character after a block?
    - `lstrip_blocks` - remove whitespace before a block?

    these properties can be configured in two ways:

    - in a `template` task definition, eg:
        ```yaml
        - name: ...
          template:
            ...
            trim_blocks: true   # this is actually the default
            lstrip_blocks: true # by default this is false
        ```
    - or in jinja template file itself, at the very top of the file:
        ```yaml
        #jinja2: trim_blocks: True, lstrip_blocks: True
        ---
        line1: ok
          {% if something %}
        line2: ok
          {% end %}
        line3: ok
        ```

    In general, the way I want it is to set `true` for **both** of them.

- next trix go here

