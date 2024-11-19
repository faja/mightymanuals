---
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