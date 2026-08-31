# AUTH

## NOTES

couple of notes: `redis` has a concept of users and passwords:
- if we start redis-servicer WITHOUT `requirepass` - it esentially disables AUTH - we running redis with no AUTH
- `requirepass` sets password for `default` user - which is the default username when we connect to redis
  with using redis-cli or client library - hence it might seem like there is no concept of a username - but there is,
  it's just "hidden"
  ```sh
  redis-cli -a ... # this is enough, --user is by default `default`
  ```
  ```sh
  # run `ACL LIST` to see the default user
  > ACL LIST
  1) "user default on sanitize-payload #ba7... ~* &* +@all"
  ```

- `ACL SETUSER ${username} on >${password} ...` - configures user and password
  ```sh
  redis-cli --user ${username} --pass ${password} -h redis ...
  ```

## IMPORTANT

ACL commands are not propagated via replication neither cluster.
They are NODE-local configuration.

## `ACL SETUSER`

```sh
ACL SET USER ${username} on >${password} ${key_selector} ${pub_sub_selector} ${commands...}
```

```sh
# admin full access user
ACL SETUSER admin on >${password} ~* &* +@all # same as default user configured with `requirepass`

# common user
ACL SETUSER ${username} >${password} ~* resetchannels +@read +@write -@dangerous +select
# long story short: RW permission to all keys, no pub/sub, minus admin like commands, plus select
# ~*             - access to all keys
# resetchannels  - no pub/sub access
# +@read +@write - RW access
# -@dangerous    - removes commands like FLUSHALL, FLUSHDB, CONFIG, MONITOR, etc... (find all with ACL CAT dangerous)
# +select        - add SELECT for a user, if not needed, can be skipped

# common user for redis cluster,
# cluster user requires a bit more commands to function correctly
ACL SETUSER ${username} >${password} ~* resetchannels +@read +@write -@dangerous +select +cluster|slots +cluster|shards +cluster|nodes +asking +readonly +readwrite
# cluster rleated commands:
# +cluster|slots +cluster|shards +cluster|nodes +asking +readonly +readwrite
# +readonly +readwrite - if client reads from replicas
```

## `ACL LIST`, `ACL GETUSER`

```sh
> ACL LIST
> ACL GETUSER ${username}
```

## categories

categories are sets of commands, that we use with `@`, with `ACL SETUSER ...`, eg: `+@read`, `+@write`

```sh
> ACL CAT               # list all command categories
> ACL CAT ${category}   # get details about a command
```
