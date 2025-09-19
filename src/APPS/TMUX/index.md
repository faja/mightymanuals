---

`mightyrcfiles/.tmux.conf`

---


# shortcuts

<span style="color:#ff4d94">**NOTE**</span> some shortcuts are custom ones
other may be default

### session

key | action
-|-
`prefix` + `S` | select session
`prefix` + `L` | last used session
`prefix` + `(` | previous session
`prefix` + `)` | next session
`prefix` + `$` | rename session

### todo
key | action
-|-
<span style="color:#ff4d94">**CTRL**</span>-`s` + `:` | prompt for a tmux command
<span style="color:#ff4d94">**CTRL**</span>-`s` + `r` | reload tmux config
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
tmux swap-window -s 2 -t 1 | swap window 2 and 1 in place
tmux move-window -s 1 -t 99 | move window 1 to position 99
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

