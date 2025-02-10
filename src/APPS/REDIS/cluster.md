### docs
- [official docs](https://redis.io/docs/latest/operate/oss_and_stack/management/scaling/)
- [cluster specification](https://redis.io/docs/latest/operate/oss_and_stack/reference/cluster-spec/)

---

- [cluster config options](#cluster-config-options)
- [redis-cli -c](#redis-cli--c)
- [cluster management](#cluster-management)

---

# cluster config options
- tldr; my prod config
    ```sh
    # note, this contain cluster options only
    cluster-enabled yes
    cluster-config-file /data/nodes.conf
    cluster-node-timeout 3000 # 3s
    cluster-port 0 # port + 10_000
    cluster-replica-validity-factor 0 # always consider itsefl a vlid replica
    cluster-migration-barrier 1
    cluster-require-full-coverage yes # do not accept writes if any key space is not covered
    cluster-allow-reads-when-down no # do not accept reads if cluster is marked as down
    cluster-allow-pubsubshard-when-down no # do not accept pubsub if cluster is marked as down
    ```

- all options
    ```sh
    cluster-enabled yes
    cluster-config-file /data/nodes.conf
    cluster-node-timeout 3000 # 3s
    cluster-port 0            # (default) 0 means port + 10_000
    cluster-replica-validity-factor 0 # setting to non zero, causes replica to
      # calculate if it is valid to become a master during a failover
      # see oficial docs, but tldr; if it's been disconnected from master
      # for too long, it may have out of sync data, hence it won't failover
    cluster-migration-barrier 1 # this is interesting one, see official docs,
      # but tldr; if master has more then specified numer of replicas,
      # it can allow "free" replica to be migrated to other master if it is missing
      # one ("autobalance" thing)
    cluster-require-full-coverage yes # (default) - if yes - cluster stopps accepting
      # writes if some percentage of the key space is not covered by any node
      # aka, all masters must be up and all keys must be covered
    cluster-allow-reads-when-down no # (default) - if no - do not accept reads
      # if cluster is marked as down - quorum can't be reached or there is no
      # full coverage of keys
    cluster-allow-pubsubshard-when-down no # if no - do not accept pubsub traffic
      # if cluster is marked as down
    cluster-replica-no-failover no # if set to yes, disables automatic failover
      # note: manual failover is still doable

    # hostname announcement:
    # cluster-announce-hostname ...
    # cluster-preferred-endpoint-type hostname

    # NAT support:
    # cluster-announce-ip
    # cluster-announce-port
    # cluster-announce-tls-port
    # cluster-announce-bus-port
    ```
    for details go to [official example config](https://redis.io/docs/latest/operate/oss_and_stack/management/config-file/)
    and search for `# REDIS CLUSTER`

# redis-cli -c

```sh
# please note to use `redis-cli` with cluster mode use `-c`
redis-cli -c
  > set foo bar
```
# cluster management

```sh
# first of, to get some help
redis-cli --cluster help

################################################################################
# create 3 nodes (masters) cluster
# we will add more nodes (replicas) later
redis-cli --cluster create \
  node20:6379 node21:6379 node22:6379 \
  --cluster-replicas 0 --cluster-yes

################################################################################
# get cluster info/check
redis-cli --cluster info 127.0.0.1:6379   # get basic cluster info
redis-cli --cluster check 127.0.0.1:6379  # perform some basic cluster checking
redis-cli CLUSTER NODES                   # or with classic redis client
# see https://redis.io/docs/latest/commands/cluster-nodes/ for output explanation

################################################################################
# reshard (rebalance) slots
# note: this is interactive, the command will ask you everything
#       how many slots, from where to where, etc...
redis-cli --cluster reshard 127.0.0.1:6379
# reshard (rebalance) NON-interactive
redis-cli --cluster reshard <host>:<port> \
  --cluster-from <node-id> --cluster-to <node-id> \
  --cluster-slots <number of slots> --cluster-yes

################################################################################
# manual failover
# on the replica of the master you wanna failover:
# https://redis.io/docs/latest/commands/cluster-failover/
redis-cli CLUSTER FAILOVER

# automatic failover
# please note "usually" it just happens if master fails, BUT!
# please note that for automatic failover to work correctly there are some
# config options that must be set correctly:
#   cluster-replica-no-failover no    # if set to yes, that disables automatic failover
#   cluster-replica-validity-factor 0 # if set to some value, it may block
#     # automatic failover if replica lag is too big

################################################################################
# add a node
# TODO
```
