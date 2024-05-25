---

`exitsnoop` traces when processes exit, showing their age and exit reason

---

```sh
# exitsnoop
PCOMM            PID    PPID   TID    AGE(s)  EXIT_CODE
cmake            8994   8993   8994   0.01    0
sh               8993   8951   8993   0.01    0
sleep            8946   7866   8946   1.00    0
cmake            8997   8996   8997   0.01    0
sh               8996   8995   8996   0.01    0
make             8995   8951   8995   0.02    0
cmake            9000   8999   9000   0.02    0
sh               8999   8998   8999   0.02    0
git              9003   9002   9003   0.00    0
DOM Worker       5111   4183   8301   221.25  0
sleep            8967   26663  8967   7.31    signal 9 (KILL)
git              9004   9002   9004   0.00    0
[...]
```
