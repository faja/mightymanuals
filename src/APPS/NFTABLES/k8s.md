---

# NFTABLES and K8S notes
- never use `flush ruleset` in nftables config file or scripts when sharing with kube-proxy
- use custom named tables — don't define rules directly in a generic inet filter that might collide
- `forward` policy should be `accept` or very carefully crafted to allow pod CIDRs
- check priorities if you need ordering guarantees relative to kube-proxy's chains
- after any kube-proxy restart, do `nft list ruleset` to verify its tables came back correctly
- also worth doing `nft monitor` the first time the cluster "starts" - to watch exactly what kube-proxy is injecting

# /etc/nftables.conf

```yaml
# Only flush YOUR table, not everything
table inet my_filter;
delete table inet my_filter;

table inet my_filter {
    chain input {
        type filter hook input priority filter; policy drop;

        iif lo accept
        ct state invalid drop
        ct state established,related accept
        icmp type echo-request accept
        icmpv6 type echo-request accept
        tcp dport { 22, 6443 } accept    # SSH + k8s API server
    }

    # Leave forward permissive — let kube-proxy handle it
    chain forward {
        type filter hook forward priority filter; policy accept;
    }

    chain output {
        type filter hook output priority filter; policy accept;
    }
}
```
