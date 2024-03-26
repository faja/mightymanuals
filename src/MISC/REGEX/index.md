[regex101](https://regex101.com/)

---

### basics
```
?          # zero or one
*          # zero or more
+          # one or more
.          # any character

\?         # escape

{3}        # range, exactly three
{1,3}      # range, between one and three
{3,}       # range, three or more
[...]      # collection
[0-9A-F]   # character ranges
[^...].    # negation

           # space is just a space
\t         # tab
\n         # new line

^          # beginning of the string
$          # end of the string
```

### character classes
```
\s   # whitespace [\r\n\t\v\f ]
\S   # not whitespace [^\r\n\t\v\f ]
\d   # digit [0-9]
\D   # not digit [^0-9]
\w   # word [0-9A-Za-z_]
\W   # not word [^0-9A-Za-z_]
\b   # word boundry - (^_HERE_\w|\w_HERE_$|\W_HERE_\w|\w_HERE_\W)
\B   # not word boundry -
```

### flags
```
/.../FLAGS_GO_HERE

/.../g   # global           - match as many times as you can,
                              without flag = only once,
                              this is usually what we WANT
/.../m   # multi-line       - match ^ and $ as the beginning and end of each line,
                              not beginning and end of string
                              this is usually what we WANT
/.../i   # case-insensitive - match upper or lower case
/.../s   # single string    - dot(.) matches new line character as well


# NOTE! using flags - syntax for flags - is platform depended!
```

### greedy vs lazy
```
# on some platforms "greede vs lazy" is control by a flag, on some other
# by a regex syntax

# greedy - take everything you can and still match
# lazy   - take as little characters as you can and still match

*?   # eg: /la*?/ # lazy matching - zero or more (*) but lazy (?)
```

### groups
```
(...)            # capturing group
\1               # captured value of group 1 - to be used later in a regex
                   but syntax vary by platform
$1               # captured value of group 1 - to be used later in a substitution
                   but syntax vary by platform
(?:...)          # non-capturing group
(?<_NAME_>...)   # named capturing group - (but syntax vary by platform)
(...)?           # optional group
(...|...|...)    # multi character group
```

### lookarounds
```
# lookarounds are part of regular expression but are not part of the match
# support for these is platform specific

(?=...)   # positive lookahead
(?!...)   # negative lookahead

(?<=...)   # positive lookbehind
(?<!...)   # negative lookbehind

# because this is quite advanced thingy, lets have a look on an example
/(?<=USD )[\d\.]+/
USD 34.75            # -> the match here is "34.75"

```
