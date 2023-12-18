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
- note: if running in a NATed environment, docker, k8s, nomad, etc...
  might be needed to add
    ```sh
    --replica-announce-ip 5.5.5.5 --replica-announce-port 1234
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

#### important note on clients behaviour
- first of all, this type of HA is not really HA, as it requires manuall failover
  however in scenarios where it is good enought, might be a good choice,
  especially if we wanna reduce the complexity
- it is important to configure the `CLIENTS` to do the **`RE-RESOLVE`** (address
  lookup) and **`RE-CONNECT`** in case of any of the following:
    - could not connect - this might be master went down, and we are doing unplanned
      failover or something like that
    - clinet got diconnected - this might be temporairly master restart or something
      simillar
    - client could not write - redis instnace is in READONLY mode - this most likely
      mean, there was a FAILOVER, and client should re-resolve (most likely
      master address got changed) and re-connect


#### planned manual failover
- **`STAGE 1`** - all the clients are connected to current master, and we plan, to
  switch master to current slave
- **`STAGE 2`** - FAILOVER
    - step 1 - DNS UPDATE - we need to update dns first, so whatever address clients
      are using to connect to redis, will be pointing to NEW MASTER (currently
      slave)
    - step 2 - check replication lag
      ```sh
      > INFO replication
      ```
    - step 3 - perform failover, on master:
      ```sh
      > FAILOVER
      ```
    - step 3 - once failover is done, all the clients won't be able to perform
      any WRITE operations, the clients will get `READONLY` message back, and
      they must `re-resolve && re-connect` to the new master
- **`STAGE 3`** - final checks - check replication status and clean all clients
  still connected to old master
    ```sh
    > INFO replication
    > CLIENT LIST
    > CLIENT KILL ID $id
    ```

#### unplanned manual failover
- **`STAGE 1`** - all the clients are connected to current master, and suddenly
  clients are getting errors, diconnections, cound not connect..etc..
- **`STAGE 2`** - master recovery check
    - so very first thing is to double check if quick master recovery is possible,
        - if **`YES`**, most likely easier to quickly recover
        - if **`NOT`**, we have to make sure, master won't start and won't accept
          any further writes, as this might cause some split brain thingy
            - this might be done by reconfiguring master to listen on localhost
                ```sh
                > bind 127.0.0.1
                ```
    - this really depends how we deploy our redis master<->slave cluster, in most
      cases it probably should be possible to recover master, but if not, lets
      continue to stage 3
- **`STAGE 3`** - FAILOVER
    - step 1 - DNS UPDATE - we need to update dns first, so whatever address clients
      are using to connect to redis, will be pointing to NEW MASTER (currently
      slave)
    - step 2 - GET CURRENT SLAVE OFFSET - this will be needed to figure out if
      we lost any writes once master went down
        ```sh
        > INFO replication
        ```
    - step 3 - promote the become master, and enable writes
        ```sh
        > replicaof no one
        ```
    - at this step all clients should reconnect to new master and start writing to it
- **`STAGE 4`** - CHECK MASTER for MISSED WRITES
    - lets start MASTER in READ ONLY mode - we do not want any new writes happening
      to the old master, this can be done by start listening on localhost
        ```sh
        > bind 127.0.0.1
        ```
    - check replication offset - by doing it and comparing with the offset
      on slave before failingover we can know if we lost any writes and if some
      extra action is needed
        ```sh
        > INFO replication
        ```
- **`STAGE 5`** - start old master as new slave
