# table of content
- [include](#include)
- [folding](#folding)
- [colours](#colours)
- [custom width](#custom-width)

```md
- [include](#include)
- [folding](#folding)
- [colours](#colours)
- [something with spaces](#something-with-spaces)
```

number of `#` does not matter

# include
the below prints `compose.yaml` file "code block" formatted
```
\```yaml
\{{#include compose.yaml}}
\```
```

# folding
```
<details>
<summary>your title here</summary>
normal stuff goess here
</details>
```

<details>
<summary>your title here</summary>
normal stuff goess here
</details>


# colours
```
<span style="color:#ff4d94">**CTRL**</span>
<span style="color:#ffff66">**SUPER/CMD**</span>
<span style="color:#99ff66">**ALT/OPTION**</span>
<span style="color:#33ccff">**SHIFT**</span>
```

- <span style="color:#ff4d94">**CTRL**</span>
- <span style="color:#ffff66">**SUPER/CMD**</span>
- <span style="color:#99ff66">**ALT/OPTION**</span>
- <span style="color:#33ccff">**SHIFT**</span>


# custom width
- book.toml
    ```toml
    [output.html]
    additional-css = ["custom.css"]
    ```
- custom.css
    ```css
    :root {
      --content-max-width: 80%;
    }
    ```
