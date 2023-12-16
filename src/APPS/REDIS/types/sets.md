# types SETS
- [official docs](https://redis.io/docs/data-types/sets/)
- [sets commands](https://redis.io/commands/?group=set)

```redis
> SADD ${set_name} ${set_item}                # add item to a set
> SADD ${set_name} ${set_item1} ${set_item2}  # add few items to a set

> SCARD ${set_name}                           # get number of items in a set

> SMEMBERS ${set_name}                        # returns all items of a set

> SISMEMBER ${set_name} ${set_item}           # returns if item is a member of a set
```
