# linux
## xterm/zsh
key | action
-|-
<span style="color:#99ff66">**ALT**</span>-`b,f,l` | jump word backward(`b`), forward(`f`,`l`)
<span style="color:#99ff66">**ALT**</span>-`d` | delete word starting from the cursor
<span style="color:#99ff66">**ALT**</span>-`t` | swap words
<span style="color:#99ff66">**ALT**</span>-`u` | capitalise next word
<span style="color:#99ff66">**ALT**</span>-`.` | paste last argument from the previous command
<span style="color:#99ff66">**ALT**</span>-`',"` | paste doubled `'`,`"` and move cursor inside
<span style="color:#99ff66">**ALT**</span>-`a` | execute command, and paste the whole buffer again, with the same cursor location <span style="color:red">[nice!]</span>
<span style="color:#99ff66">**ALT**</span>-`q` | temporary copy current buffer and clear it, once other command is executed, past it again <span style="color:red">[nice!]</span>
---|---
<span style="color:#ff4d94">**CTRL**</span>-`m` | \<enter\>
<span style="color:#ff4d94">**CTRL**</span>-`j,o` | also \<enter\> but most likely +some magic stuff
<span style="color:#ff4d94">**CTRL**</span>-`a,e` | move cursor to the begining,end of the line
<span style="color:#ff4d94">**CTRL**</span>-`f,b` | move 1 character forward,backward
<span style="color:#ff4d94">**CTRL**</span>-`h` | \<backspace\>
<span style="color:#ff4d94">**CTRL**</span>-`w` | delete word backwards
<span style="color:#ff4d94">**CTRL**</span>-`k` | delete from the cursor to the end of line
<span style="color:#ff4d94">**CTRL**</span>-`u` | delete whole buffer
<span style="color:#ff4d94">**CTRL**</span>-`y` | paste previously deletion (word, end of line, buffer)
<span style="color:#ff4d94">**CTRL**</span>-`l` | `clear`
<span style="color:#ff4d94">**CTRL**</span>-`n,p` | history next,prev command
<span style="color:#ff4d94">**CTRL**</span>-`r` | history search
<span style="color:#ff4d94">**CTRL**</span>-`d` | SIGQUIT (3)
<span style="color:#ff4d94">**CTRL**</span>-`c` | SIGINT (2)
<span style="color:#ff4d94">**CTRL**</span>-`s` | "freeze"
<span style="color:#ff4d94">**CTRL**</span>-`q` | un"freeze"

## tmux
[tmux shortcuts](../../APPS/TMUX/index.md)

## vim

# macos
## iterm/zsh
Same as `linux`, but:
- CTRL-s "freeze" - does not work
- CTRL-q un"freeze" - does not work
- all ALT- shortcuts requires remapping in iterm settings
    - go to settings
    - go to keys
    - `+`
    - "Send Escape Sequence"
- ALT '," - does not work

## tmux
Same as `linux`
