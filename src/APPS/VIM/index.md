---

# usage

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
## md preview
```yaml
:Markview            # to toggle in buffer rendering
:LivePreview start   # to open browser based live preview
```

## git related
```yaml
# todo
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
