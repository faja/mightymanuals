---

# NFTABLES and K8S notes
- never use `flush ruleset` in nftables config file or scripts when sharing with kube-proxy
- use custom named tables — don't define rules directly in a generic inet filter that might collide
- `forward` policy should be `accept` or very carefully crafted to allow pod CIDRs
- check priorities if you need ordering guarantees relative to kube-proxy's chains
- after any kube-proxy restart, do `nft list ruleset` to verify its tables came back correctly
- also worth doing `nft monitor` the first time the cluster "starts" - to watch exactly what kube-proxy is injecting
    ```sh
    nft monitor
    ```

# /etc/nftables.conf

<details>
<summary>other option</summary>

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
</details>

```yaml
table inet filter        # create if not exists
flush table inet filter  # flush only `filter`, leave `k8s-*` tables untouched

table inet my_filter {
    chain input {
        type filter hook input priority 0
        policy drop

        iif lo accept
        ct state invalid drop
        ct state established,related accept

        ip saddr 192.168.20.0/24 icmp type echo-request accept
        ip saddr 192.168.20.0/24 tcp dport 22 accept

        # TODO LATER - K8S COMPONENTS
        # 6443        - k8s api        - control plane nodes
        # 10250       - kubelete api   - worker nodes
        # 2379-2380   - etcd           - control plane nodes
        # 30000-32767 - nodeport range - worker nodes - if NodePort is in use
        # +plus whatever custom CNI needs
    }

    chain forward {
        # should be accept, let kube-proxy handle it
        type filter hook forward priority filter
        policy accept
        # NOTE: for Cilium, policy can/should be drop # still to be verified
    }

    chain output {
        type filter hook output priority filter
        policy accept
    }
}
```
