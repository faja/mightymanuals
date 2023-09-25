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
key | action
-|-
<span style="color:#ff4d94">**CTRL**</span>-`s` + `:` | prompt for a tmux command
<span style="color:#ff4d94">**CTRL**</span>-`s` + `r` | reload tmux config
<span style="color:#ff4d94">**CTRL**</span>-`s` + `S` | select tmux session
<span style="color:#ff4d94">**CTRL**</span>-`s` + `$` | rename session
<span style="color:#ff4d94">**CTRL**</span>-`s` + `d` | detach
<span style="color:#ff4d94">**CTRL**</span>-`s` + `t` | display time
---|---
<span style="color:#ff4d94">**CTRL**</span>-`s` + `c,C-c` | create new window
<span style="color:#ff4d94">**CTRL**</span>-`s` + `n,<space>,C-<space>` | next window
<span style="color:#ff4d94">**CTRL**</span>-`s` + `p,<backspace>,C-<backspace>` | previous window
<span style="color:#ff4d94">**CTRL**</span>-`s` + `C-s` | jump between last used windows
<span style="color:#ff4d94">**CTRL**</span>-`s` + `1,2,3...` | jump to window number `1,2,3...`
<span style="color:#ff4d94">**CTRL**</span>-`s` + `s` | horizontal split aka `-`
<span style="color:#ff4d94">**CTRL**</span>-`s` + `v` | vertical split aka `|`
<span style="color:#ff4d94">**CTRL**</span>-`s` + `,` | rename window
---|---
<span style="color:#ff4d94">**CTRL**</span>-`s` + `[,<ecs>` | enter copy mode
<span style="color:#ff4d94">**CTRL**</span>-`s` + `C-u` | copy first arg from last line
<span style="color:#ff4d94">**CTRL**</span>-`s` + `C-i` | copy last line
<span style="color:#ff4d94">**CTRL**</span>-`s` + `C-o` | copy last arg from last line
<span style="color:#ff4d94">**CTRL**</span>-`s` + `=,C-=` | show paste buffer
<span style="color:#ff4d94">**CTRL**</span>-`s` + `C-p` | paste buffer
---|---
<span style="color:#ff4d94">**CTRL**</span>-`s` + `q` | display pane numbers
<span style="color:#ff4d94">**CTRL**</span>-`s` + `h,j,k,l,C-h,C-j,C-k,C-l`  | jump to pane left,down,up,right
<span style="color:#ff4d94">**CTRL**</span>-`s` + `z` | zoom pane
<span style="color:#ff4d94">**CTRL**</span>-`s` + `x` | kill pane
<span style="color:#ff4d94">**CTRL**</span>-`s` + `{,}` | swap panes
<span style="color:#ff4d94">**CTRL**</span>-`s` + `C-<arrows>,M-<arrows>` | resize pane
<span style="color:#ff4d94">**CTRL**</span>-`s` + `E` | resize panes evenly
<span style="color:#ff4d94">**CTRL**</span>-`s` + `>,<` | toggle pane sync
<span style="color:#ff4d94">**CTRL**</span>-`s` + `!` | convert pane into dedicated window <span style="color:red">[nice1]</span>

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
## tmux
Same as `linux`
