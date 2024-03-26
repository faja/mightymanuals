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

### ...to be continued

```
...
```
