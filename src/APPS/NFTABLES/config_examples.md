# typical /etc/nftables.conf
```sh
#!/usr/sbin/nft -f

flush ruleset

table inet filter {
  chain input {
    type filter hook input priority 0; policy drop;

    ct state invalid drop
    ct state established,related accept
    iif lo accept
    tcp dport { 22, 80, 443 } accept
  }
  chain forward {
    type filter hook forward priority 0;  policy drop;
  }
  chain output {
    type filter hook output priority 0; policy accept;
  }
}
```

# my prod bare metal server
```yaml
TODO
```

# include
"main" file can be split into smaller chunks, than use `include` in the main one
- `/etc/nftables.conf`:
```yaml
include "/etc/nftables.d/sets.conf"
include "/etc/nftables.d/filter.conf"
include "/etc/nftables.d/nat.conf"
```
# examples
## simple home server
```yaml
table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;

        iif lo accept                          # loopback
        ct state invalid drop                  # drop bad state
        ct state established,related accept    # allow return traffic
        icmp type echo-request accept          # allow ping (IPv4)
        icmpv6 type echo-request accept        # allow ping (IPv6)
        tcp dport { 22, 80, 443 } accept       # SSH, HTTP, HTTPS
    }

    chain forward { type filter hook forward priority 0; policy drop; }
    chain output  { type filter hook output  priority 0; policy accept; }
}
```

## nat router
```yaml
table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;

        iif lo accept
        ct state invalid drop
        ct state established,related accept
        iif eth1 tcp dport 22 accept           # SSH from LAN only
        icmp type echo-request accept
    }

    chain forward {
        type filter hook forward priority 0; policy drop;

        ct state established,related accept
        iif eth1 oif eth0 accept               # LAN → WAN
    }

    chain output { type filter hook output priority 0; policy accept; }
}

table ip nat {
    chain postrouting {
        type nat hook postrouting priority 100;
        oif eth0 masquerade                    # NAT outbound traffic
    }
}
```

## rate limiting and brute-force protection
```yaml
table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;

        iif lo accept
        ct state invalid drop
        ct state established,related accept
        icmp type echo-request limit rate 5/second accept

        # Allow max 3 new SSH connections per minute per source IP
        tcp dport 22 ct state new \
            limit rate over 3/minute \
            log prefix "SSH brute-force: " drop

        tcp dport 22 ct state new accept
        tcp dport { 80, 443 } accept
    }

    chain forward { type filter hook forward priority 0; policy drop; }
    chain output  { type filter hook output  priority 0; policy accept; }
}
```

## using sets for ip allowlisting/blocklisting
```yaml
table inet filter {
    # Blocked IPs — can be updated live with: nft add element inet filter blocklist { 1.2.3.4 }
    set blocklist {
        type ipv4_addr
        flags dynamic, interval
        elements = { 10.0.0.5, 198.51.100.7 }
    }

    # Trusted admin IPs allowed to SSH
    set ssh_allow {
        type ipv4_addr
        elements = { 192.168.1.10, 192.168.1.20 }
    }

    chain input {
        type filter hook input priority 0; policy drop;

        iif lo accept
        ct state invalid drop
        ct state established,related accept

        ip saddr @blocklist drop                 # drop blocklisted IPs early
        ip saddr @ssh_allow tcp dport 22 accept  # SSH for trusted IPs only
        tcp dport { 80, 443 } accept
    }

    chain forward { type filter hook forward priority 0; policy drop; }
    chain output  { type filter hook output  priority 0; policy accept; }
}
```

## port knocking (simple 2-stage)
```yaml
table inet filter {
    set knockers {
        type ipv4_addr
        flags dynamic, timeout
        timeout 10s # knock valid for 10 seconds
    }

    chain input {
        type filter hook input priority 0; policy drop;

        iif lo accept
        ct state invalid drop
        ct state established,related accept

        # Stage 1: hitting 7000 adds IP to knockers set
        tcp dport 7000 add @knockers { ip saddr }

        # Stage 2: SSH only open if IP is in knockers set
        ip saddr @knockers tcp dport 22 accept

        tcp dport { 80, 443 } accept
    }

    chain forward { type filter hook forward priority 0; policy drop; }
    chain output  { type filter hook output  priority 0; policy accept; }
}
```
