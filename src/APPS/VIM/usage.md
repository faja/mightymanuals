---

# base usage
# plugin related usage

## git related
```yaml
################################################################################
# open a file in on a specific commit
# using fugitive
:Gedit ${commit_sha}:path/to/a/file.txt
# using diffview
:DiffviewFileHistory %
# find the commit you wanna open the file in
# it opens in a diff mode, simply quit the side you don't want
```

# TODO

## nvim tree
```yaml
# keybindings
E     # expand all
W     # collaps all
H     # toggle .dot files
J     # last sibling
K     # first sibling
P     # parent
m     # mark
bd    # delete marked
```
## markdown preview
```yaml
:Markview            # to toggle in buffer rendering
:LivePreview start   # to open browser based live preview
```


## treesitter
```yaml
:InspectTree    # to inspect treesitter tree - but also quite nice to just check
                # if treesitter is working for a current filetype
:TSInstallInfo  # check what parsers are installed
:TSModuleInfo   # check if highlighting is enabled
```
## surround
```yaml
ds"   # remove surrounded " ... "example to test"
cs"'  # replace " with '    ... "example to test"
```

## fzf-lua
```yaml
### fzf window
tab     - select
alt + a - toggle all
alt + q - send selected to quick fix list
alt + g - jump to the first
alt + G - jump to the last
-
### preview window
shift down/up - to scroll down/up a page
shift left    - reset preview aka go to the top
```

# nvim startuptime

```sh
nvim --startuptime startuptime.log
```

# config
##

## fresh config installation
```sh
# tmp new installation
cd .config
rm -rf ~/.config/nvim.back && mv ~/.config/nvim{,.back}
rm -rf ~/.local/share/nvim.back && mv ~/.local/share/nvim{,.back}
rm -rf ~/.cache/nvim.back && mv ~/.cache/nvim{,.back}
```

# tips & trix

### OMG! re-indent magic with `=`
- to reindend a selection, simply select few lines and press `=`
- to magically reindend the whole file: `gg=G`
    - `gg` - go to the top
    - `=`  - reindent
    - `G`  - go to the bottom


### reverse order of lines
    - entire file
    ```
    :g/^/m0
    ```
    - visual selection:
    ```
    :'<,'>g/^/m${FIRST_LINE_NUMBER-1}`
    ```
    where FIRST_LINE_NUMBER, is the first line number of the selection,
    eg, if we wanna revers lines from 10 to 15: `g/^/m9`

### TODO
```
-- VIM TIPS AND TRIX USAGE HOWTO: TODO MOVE THIS TO MANUALS {{{
--[[

<c-w>T - move current window to new tab

:set            - shows vars different from defaults
:set all        - shows all values
:set foo?       - shows the value of foo
:set foo+=opt   - add opt to the value w/o changing others
:set foo-=opt   - remove opt from value
:set foo&       - reset foo to default value
:setlocal foo   - only the current buffers

:set textwidth=0
:set wrapmargin=0

{{{ fugitive
# add patch
- go to status `:G`
- put cursor on a file, and hit `i`
- visual block/line you want to add, and use `-` to stage/unstage

# :Git blame
- `g?` - for help
- `-`  - reblame at the commit          - this basically means - rerender the file at this particular commit
- `P`  - reblame at the previous commit - this measn - show me how the file looked like before this one was added

# navigate through the Gclog
- open a file
- :Gclog -- %    - this is pretty cool, it will show you all the commits related to this file
- select a commit you want to interact with
- navigate to the changed file with `]m`
- then you can press `o`(- split), `gO` (| split), or `O` (new tab) to open
    - a diff
    - how the file looked liek BEFORE the change
    - how the file looks liek AFTER the change

# :Gedit
- `:Gedit HASH:file` - opens a file at a specifc commit
- `:Gedit HASH:%` - opens current file ata specific commit
}}}

{{{ vim diff (normal diff)
            ]c - jump to next change
            [c - jump to prev change
}}}

{{{ diffview
# see changes for a single path or file
  :DiffviewOpen 5618c3e5bf62847c1b9f7420783ec27dd438244e..b386ffca433ed6a49b76147758857d1a4f84caba -- vpc/outputs.tf
this is equivalent of
  git diff 5618c3e5bf62847c1b9f7420783ec27dd438244e..b386ffca433ed6a49b76147758857d1a4f84caba vpc/outputs.tf

# see history for current file
  :DiffviewFileHistory %

# nice flow
  1. open diffview
  2. select a file then "gf" to open it in previous tab
  3. :DiffviewFileHistory %

}}}

{{{ telescope

- TAB - mark an item
- CTRL+Q - open ALL items in a quick list
- ALT+Q  - open marked items in a quick list

-- search syntax for FZF ~> https://github.com/junegunn/fzf#search-syntax
- one simple example is: `!foobar` - items that do not include `foobar`

}}}

{{{ mason
-- keybindings
<CR>  : toggle_package_expand
i     : install_package
u     : update_package
c     : check_package_version
U     : update_all_packages
C     : check_outdated_packages
X     : uninstall_package
}}}

{{{ :!execute a command
:!ls        # executes a command `ls` and puts the output to a tmp buffer
:.!ls       # executes a command `ls` and puts the output to THE CURRENT BUFFER

# visual select a line(s) the !<command> # this will take the selected lines as an input to <command>
# handy example is to use `jq` to format single line json to pretty printed
# {"ok": "thisisnotformatedjson"}
# :'<,'>!jq
}}}

-- how to disable/enable diagnostics
    :lua vim.diagnostic.disable()
    :lua vim.diagnostic.enable()
--]]
-- }}}
```

# LUA TLDR;
```lua
-- simgle line comment

--[[
  multi line comment
--]]

-- requiring
require("my_custom_stuff") -- that would call ~/.config/nvim/lua/my_custom_stuff.lua

-- create local variable and reuse it for conciseness
local opt = vim.opt
opt.number = true -- instead of vim.opt.number = true


-- call some function and check the status
local colorscheme = "xxx"
local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not status_ok then
    print("Colorscheme " .. colorscheme .. " not found")
    return
end
```
