---

# usage

- md preview
    ```sh
    :Markview            # to toggle in buffer rendering
    :LivePreview start   # to open browser based live preview
    ```

- git related
    ```sh
    # todo
    ```

# nvim startuptime

```sh
nvim --startuptime startuptime.log
```

# tips & trix

- reverse order of lines
    - entire file
    ```
    :g/^/m0
    ```
    - visual selection:
    ```
    :'<,'>g/^/m${FIRST_LINE_NUMBER-1}`
    ```
    where FIRST_LINE_NUMBER, is the first line number of the selection,
    eg, if we wanna revers lines from 10 to 15: `g/^/m14`
