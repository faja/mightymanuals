---

dns configuration is split into two sections:
- [resolvers](https://docs.haproxy.org/2.8/configuration.html#5.3) - top level config section
-  resolver related server options [resolvers](https://docs.haproxy.org/2.8/configuration.html#5.2-resolvers), [resolve-prefer](https://docs.haproxy.org/2.8/configuration.html#5.2-resolve-prefer), [init-addr](https://docs.haproxy.org/2.8/configuration.html#5.2-init-addr)

### resolvers - top level config section
the `resolvers` section itself can be divided into three parts
```
resolvers dns

    # my rule of thumb aka TLDR:
    # nameserver dns 127.0.0.1:53
    # accepted_payload_size 8192
    # resolve_retries 1
    # timeout resolve 1s
    # timeout retry   1s
    # hold valid      3s
    # hold other      10s
    # hold refused    10s
    # hold timeout    10s
    # hold nx         3s
    # hold obsolete   3s

    # part 1 the nameserver itself and the payload
    nameserver dns 127.0.0.1:53
    # parse-resolv-conf # useful if we wanna use default nameserver configuerd
                        # in /etc/resolv.conf istead of defining ones with
                        # `nameserver` directive, however I tend to just use
                        # `nameserver` directive
    accepted_payload_size 8192 # default is 512
                               # recommended is 8192 so please always usse that

    # part 2 - timeouts and retries
    # set all the below to 1 - to trigger name resolution every 1s
    # no matter if the previous query failed or was successfull
    resolve_retries 1  # number of queries to send to resolver before giving up
    # the word `timeout` is a bit missleading here - it actually means - `wait`
    # how much time to wait before triggrting the next resolution
    timeout resolve 1s # this is basically how often to do name resolution
    timeout retry   1s # time between two queries, when no valid response have
                       # been reveived

    # part 3 - HOLD - the most important one
    # NOTE! this section is kinda tricky
    # please also NOTE that the actual `UP` state of a server also depends
    # on the health check!

    # in general the syntax is: `hold <state> <period>` and it means
    # if you received <state> type of resonse from DNS keep the previous valid
    # resolutions for <period> of time

    # lets start with the easy ones:
    hold valid    3s # it does not affect dynamic resolution of servers,
                     # applies only to "http-request do-resolve" and
                     # "tcp-request content do-resolve" actions
                     # can be set to any value, but lets keep it as 3s

    hold other    10s # if received any "other" invalid response from DNS server
                      # keep previously resolved ip addresses from periof of time
                      # 10 seconds

    hold refused  10s # if DNS server responses with `REFUSED` status
                      # keep previously valid responses from time window of 10s

    hold timeout  10s # once we used all retries, and the connection is still timing out
                      # keep previously valid responses from time window of 10s

    hold obsolete 3s # this will keep the old record for time Xs once its gone from DNS
                     # for specified preriod of time, but there must be some other
                     # record returned, at least once, if no more records are returned
                     # then "hold nx" applies!
                     # this one is pretty interesting and the value depends on
                     # how dns records are being returned by DNS server
                     # often DNS server does not return all values it has, for instance
                     # if there are 10 dns records for a single name,
                     # DNS server may return random 3 of them
                     # in this case we wanna set it to something like 5*interval
                     # but if our DNS server always returns all values it is aware of
                     # probably value of 1s makes more sense
                     # something in beetween like 3s is a good tradeof I guess

    hold nx       3s # this applies only if DNS server returned NO records
                     # aka NXDOMAIN response, in this case we can keep previously
                     # valid response from Xs time window

# to distinguish between obsolete and hold, a scenario:
# - there are two UP backends: backend01 and backend02
# - once DNS response returns only one entry backend02, then backend01 is being removed after "hold obsolete"
# - once DNS response returns no entries (NX) -> then the "stale" record, that is backend02, is being kept for "hold nx" time
```

### resolver related server option
```sh
# usually we wanna set the following
#   resolvers $NAME_OF_THE_RESOLVERS_SECTION
#   resolve-prefer ipv4 - as the default is ipv6
#   init-addr last,libc,none - which means during the start it would first try
#                              to get ip address from the saved state file
#                              then from the internal resolver, and the last
#                              `none` means it would not fail the start if it
#                              can not find the adress
# so:

server ....... resolvers mydns resolve-prefer ipv4 init-addr last,libc,none

# it's save to always use that settings ^^
```
