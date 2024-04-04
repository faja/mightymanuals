### hex to dec, dec to hex

```sh
printf "dec:%d hec:%x\n" 34 34      # dec to hex
printf "hex:%d dec:%x\n" 0xFF 0xFF  # hex to dec
```
or
```sh
print $(( [##16]10#$1 ))  # dec to hex
print $(( [#10]16#$1 ))   # hex to dec
print $(( [##2]10#$1 ))   # dec to bin
```

