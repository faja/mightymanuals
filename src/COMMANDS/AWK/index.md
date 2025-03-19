
- [syntax](#syntax)
- [usage examples](#usage-examples)
- [some advanced trix](#some-advanced-trix)

---

# syntax

- field separator
    ```sh
    -v FS    # field separator, defaul  ' '
             # -vFS=":" is the same as -F:
    -v RS    # record(line) separator, default '\n'
    -v OFS   # output field separator pol
    -v ORS   # output record(line) separator


    ```

# usage examples
```sh
awk '/pattern/'                 # any element match
awk '!/pattern/'                # any alement must NOT match
awk '$1 ~ /pattern/'            # 1st element matches
awk '$1 == "pattern"'           # exact match
awk '$1 !~ /pattern/'           # 1st element DOES NOT match
awk '$1 ~ /pattern/ {print $2}' # 1st element matches but print only second one
awk '/foo/ && /bar/'            # must match /foo/ AND /bar/
awk '/foo/ && !/bar/'           # must match /foo/ but NOT /bar/
awk '/foo/ || /bar'             # must match /foo/ OR /bar/

awk '/OK/ {print NR" "$0}' # add line number to printed line

awk 'NF' # skip empty lines! nice

awk 'NR == 2' # print 2nd line only
awk 'NR >= 2' # start from 2rd line
awk 'NR >= 2' # start from 2rd line

awk '/OK/ && NR > 2' # print lines that mach regex but start from 3rd line

awk '/OK/ {print;exit;}' # print first match only
```

### handy one liners
```sh
# print columns starting from 3rd to the end
# useful if we don't know the number of columns or it is dynamic
awk '{for(i=3;i<=NF;++i)printf $i""FS;printf ORS}' test.txt

# create a one line form multiple lines:
awk -vFS=: -vORS=, '{print $1}' test.txt | sed 's/.$//'

# use awk to print per second rate
# -W interactive, bc awk sometimes doesn't flush every second;/
awk -W interactive '{val=$1-val_p;val_p=$1;print "packets total:",val_p,", p/s:",val}' \
  <(while true; do cat /sys/class/net/eth0/statistics/rx_bytes ; sleep 1;done)

# print processes spawned by sshd
ps -eF --forest | awk '$11 ~ /\/usr\/sbin\/sshd/{p=1} $11 ~ /^\// && $11 !~ /\/usr\/sbin\/sshd/{p=0} p'

# split line into multiple lines, aka `tr " " "\n"`, and print filed number
awk '/^TcpExt/ && NR==1 {gsub(" ","\n");print}' /proc/net/netstat | awk '{print NR, " : ", $0}'

# build a handy tmp map, then use for to print all it's values,
# use second item ($2) as a map key
awk -F, '$1 == "rcv" { a[$2]++ } END { for (s in a) { print s, a[s] } }' out.tcpwin01.txt
```

# some advanced trix

[awk trix blog post](https://catonmat.net/ten-awk-tips-tricks-and-pitfalls)

## environment variable as pattern
```sh
awk -vpattern="${SOME_VARIABLE}" '$1 == pattern {print $2}'
awk -vpattern="${SOME_VARIABLE}" '$1 ~ pattern {print $2}'
awk -vpattern="^OK" '$0 ~ pattern {print NR" "$0}'


```

## print between matches

```sh
awk '/begin/,/end/'               # from BEGIN till END, include BEGIN and END
awk '/begin/{p=1};p;/end/{p=0}'   # same
awk '/end/{p=0};p;/begin/{p=1}'   # from BEGIN till END, but exclude BEGIN and END

awk '/begin/{p=1} p'              # from BEGIN to the end of a file

awk '/begin/{p=1} /end/{p=0} p'   # from BEGIN till END, exclude END
awk 'p; /begin/{p=1} /end/{p=0}'  # from BEGIN till END, include END
```

