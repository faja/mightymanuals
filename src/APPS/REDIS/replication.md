### docs
- official [docs](https://redis.io/docs/management/replication/)

### TLDR configuration/startup
- start `master` with [persistance](./persistance.md) of your choice
- start `replica` with replicaof option, you can do it via:
    - config file
        ```sh
        replicaof master-address master-port
        ```
    - cmd line
        ```sh
        --replicaof master-address master-port
        ```
    - on the fly via CLI
        ```sh
        > replicaof master-address master-port
        ```

### commands/howtos
- get info about replication both on `master` and `replica`
    ```sh
    > INFO replication
    ```

- promote a `replica` to be a `master`, NOTE: this is not failover or anything like that
  this is more "I was a replica, but now I just want to disconnect from
  master and forget about the replication at all"
    ```sh
    > REPLICAOF no one
    ```

- allow writes to `replica` (by defaults replicas are READ ONLY)
    ```sh
    > CONFIG SET slave-read-only no
    ```


- special `master` config: allow writes to master only if particular number of
  replicas are connected and they are not lagging more than xs
    ```
    min-replicas-to-write <number of replicas>
    min-replicas-max-lag <number of seconds>
    ```

### scenarios

#### planned manual failover
todo
#### unplanned manual failover
todo
