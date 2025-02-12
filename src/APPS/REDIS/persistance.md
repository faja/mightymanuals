---

### docs
- [official docs](https://redis.io/docs/latest/operate/oss_and_stack/management/persistence/)

---

### tldr;
There are **FOUR** persistence options:
- **RDB** (redis database) - aka point-in-time snapshots
- **AOF** (append only file) - file with all commands redis received logged
- **RDB**+**AOF**
- **NO** persistence

In general **RDB** is faster (lower latency) but **AOF** provides better durability.

And if you don't know which one to pick, a rule of thumb:
- **NO** persistence - if you don't need it, obviously
- just **RDB** alone - if you can live with a few minutes of data loss
- **RDB**+**AOF** -
- just **AOF** alone - is not recommended by `redis` authors

## persistence management

<span style="color:#ff4d94">NOTE!</span> awesome command to get info about
persistence config and stats
```
> INFO persistence
```


## RDB aka snapshotting
- binary file called `dump.rdb`
- config
    ```
    # save <seconds> <changes> [<seconds> <changes> ...]
    ## make snapshot every N seconds if at least M changes got made

    save 3600 1 300 100 60 10000
    ## * After 3600 seconds (an hour) if at least 1 change was performed
    ## * After 300 seconds (5 minutes) if at least 100 changes were performed
    ## * After 60 seconds if at least 10000 changes were performed

    # save "" # to disable RDB snapshotting

    ## file location
    # dir /var/lib/redis
    # dbfilename dump.rdb # default
    ```
- you can trigger a snapshot by calling `SAVE` or `BGSAVE`

## AOF
- appendonly uses set of files:
    - base files
    - incremental files
    - manifest files (some internal metadata stuff - not data itself)
- config
    ```
    appendonly yes # yes|no
    kkk

    # dir /var/lib/redis
    # appendfilename "appendonly.aof"  # default
    # appenddirname "appendonlydir"    # default

    ## fsync config
    appendfsync everysec # always|everysec|no
    ## always   - every write operation - very very slow
    ## everysec - every second, default, good enough
    ## no       - diable forcing fsync() - just let OS to decide
    ```

## howto RDB -> AOF
> How I can switch to AOF, if I'm currently using dump.rdb snapshots?
>
> If you want to enable AOF in a server that is currently using RDB snapshots,
> you need to convert the data by enabling AOF via CONFIG command on the live server first.
>
> IMPORTANT: not following this procedure (e.g. just changing the config and
> restarting the server) can result in data loss!

> Preparations:
>
> - Make a backup of your latest dump.rdb file.
> - Transfer this backup to a safe place.

> Switch to AOF on live database:
>
> - Enable AOF: redis-cli config set appendonly yes
> - Optionally disable RDB: redis-cli config set save ""
> - Make sure writes are appended to the append only file correctly.
> - IMPORTANT: Update your redis.conf (potentially through CONFIG REWRITE)
> and ensure that it matches the configuration above. If you forget this step,
> when you restart the server, the configuration changes will be lost and the
> server will start again with the old configuration, resulting in a loss of
> your data.
