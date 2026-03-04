---

# core concepts
- `table` - this is a top-level container, however, a table is always associated with "family"
for instance (inet, arp, bridge, etc...) - so when we think about a top-level thing
it's always a pair `table` + `family` - EXAMPLE: `table inet filter`
- `chain` - chain in a table, for instance: `input`, `forward`, `output`,
chains have types: `filter`, `nat`, `route`, and hooks: `input`, `forward`, etc...
- `rule` - rule in a chain

to visualise that:
```
table inet filter:
    chain input:
        rule allow tcp to port 22
```

# basic usage
- basic usage
```sh
nft list ruleset      # list rulesets
nft -a list ruleset   # list rulesets with handle numbers

nft add table inet my_custom_table
nft add chain inet my_custom_table my_custom_CHAIN { type filter hook input priority 0\; policy drop\; }
nft add rule inter my_custom_table my_custom_CHAIN tcp dport 22 accept

nft delete rule inet my_custom_table my_custom_CHAIN handle 5 # remove rule with handle number 5

nft flush table inet my_custom_table
nft delete table inet my_custom_table
```

- rules
```sh
# basic syntax:
nft add rule <family> <table> <chain> <match> <statement>

# example matches:
ip saddr 192.168.1.0/24  # source ip
tcp dport { 80, 443 }    # dest port
iif eth0                 # incomming interface
ct state established, related  # connection tracking

# example statements:
accept
drop              # silently discards
reject            # sends back an ICMP "port unreachable" or TCP RST
log               # does not stop evaluation
counter           # does not stop evaluation
return
jump <chain>
```

- ways of flushing exisintg rules
```sh
nft flush ruleset             # flushes everything, completely, notnigh is left
nft destroy table inet filter # destroys a single table - in this case `filter`
nft delete table inet filter  # "careful" destroy, similar to destroy, but it would
  # fail if the table does not exists, or something else (for instance a jump)
  # references that table
```

# rules reload
```sh
nft -c -f /etc/nftables.conf  # check only
nft -f /etc/nftables.conf     # apply rules manually
# or
systemctl reload nftables

# NOTE: systemctl reload nftables simply run `nft -f /etc/nftables.conf`
# cat /usr/lib/systemd/system/nftables.service
# and note:
#    [Service]
#    Type=oneshot
#    RemainAfterExit=yes
# interesting
```

# safe rules reload best practice

```sh
# create a config backup, next edit the config and save
cp /etc/nftables.conf /etc/nftables.conf.bak
vim /etc/nftables.conf
nft -c -f /etc/nftables.conf

# schedule a full revert in 2 minutes
bash -c "sleep 120 && nft flush ruleset && nft -f /etc/nftables.conf.bak" &

# apply new rules
nft -f /etc/nftables.conf

# if everything looks good, cancel the revert
kill %1
```
