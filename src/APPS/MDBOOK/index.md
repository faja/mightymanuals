# table of content
- [include](#include)
- [folding](#folding)
- [colours](#colours)
- [custom width](#custom-width)
- [plugins](#plugins)

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

# plugins
## callouts
install
```
cargo install mdbook-callouts
```
configure, `book.toml`:
```
# ADD THIS
[preprocessor.callouts]
```
usage (note there should be a space between `>` and `[`):

```
>[!INFO]
> Highlights information of additional information that users should take into
> account, even when skimming.

>[!NOTE]
> Highlights information that users should take into account, even when skimming.

>[!TIP]
> Optional information to help a user be more successful.

>[!IMPORTANT]
> Crucial information necessary for users to succeed.

>[!SUCCESS]
> Success information to a user.

>[!QUESTION]
> Question for the user to consider.

>[!WARNING]
> Critical content demanding immediate user attention due to potential risks.

>[!CAUTION]
> Negative potential consequences of an action.

>[!FAILURE]
> Information about a failure.

>[!DANGER]
> Information about a danger or a hazardous situation that users need to avoid.

>[!BUG]
> Information about a bug or an issue that users need to be aware of.

>[!EXAMPLE]
> Example of a point or solution that users can apply.

>[!QUOTE]
> Quoted information that is particularly relevant or insightful.

>[!QUOTE] Custom title example
> You can set a custom title by adding the title in the same line as the tag.
```
testing:
> [!IMPORTANT]
> important

