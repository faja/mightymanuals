---

`iostat`-like networking related stats tool

imo, the best tool to display simple: packate, bytes, errors, drops, connections, etc

```sh
apt-get -y install nicstat
```

```sh
nicstat -l        # just list interfaces
nicstat 1         # print IP stats per second
nicstat -i eth1 1 # limit to a single interface
  # -U  - show Read and Write utilisation separately
  # -x  - show extended stats

# TCP
nicstat -t 1  # show tcp stats per second

# UDP
nicstat -u 1  # show udp stats per second

# see
man nicstat
# for a nice fileds description
```
