#

- [official docs](https://typesense.org/docs/)

## play

For pretty nice 3 nodes cluster playgroud see [mightyplay/typesense/00_play_k8s](https://github.com/faja/mightyplay/tree/master/typesense/00_play_k8s)

## starting a cluster

- /config/nodes
    ```sh
    # <peering_address>:<peering_port>:<api_port>
    NODE1_IP:8107:443,NODE2_IP:8107:443,NODE3_IP:8107:443
    ```

- command and arguments
    ```sh
    # using flags
    /opt/typesense-server
      --data-dir /var/lib/typesense \
      --api-key=xyz \ # note: you can replace this flag completely if TYPESENSE_API_KEY is set
      --api-address=0.0.0.0 \
      --api-port=443 \
      --ssl-certificate=/... \
      --ssl-certificate-key=/... \
      --peering-address=192.168.12.3 \
      --peering-port=8107 \
      --nodes=/config/nodes

    # using config file that contains all the args is also possible,eg:
    /opt/typesense-server --config=/config.ini
    ```

## how to upgrade

- when upgrading to a new version, upgrade followers first, then leader
  of course, do nodes, one by one, and wait for a cluster to become healthy,
  before moving to the next one

## scaling up/down
- to add an extra node:
  - add extra node to `nodes` file on all nodes, and restart the processes
  - start typesense on new node
- to remove a node:
  - remove node from `nodes` file on all nodes (except node you are removing), and restart the processes
  - stop the process you wanna remove
- note: chart in mightyplay supports this procedure pretty well

## backup and recover

TODO

## api calls aka quick curl
```sh
TYPESENSE_API_KEY=...
TYPESENSE_ADDRESS=...

# ---------------------------------------------------------------------------- #
# status/debug/health
curl -H "X-TYPESENSE-API-KEY: ${TYPESENSE_API_KEY}" "${TYPESENSE_ADDRESS}/health"
curl -H "X-TYPESENSE-API-KEY: ${TYPESENSE_API_KEY}" "${TYPESENSE_ADDRESS}/debug"
curl -H "X-TYPESENSE-API-KEY: ${TYPESENSE_API_KEY}" "${TYPESENSE_ADDRESS}/status"

# ---------------------------------------------------------------------------- #
# LEADER vote
curl -X POST -H "X-TYPESENSE-API-KEY: ${TYPESENSE_API_KEY}" "${TYPESENSE_ADDRESS}/operations/vote"

# ---------------------------------------------------------------------------- #
# peers reset
curl -X POST -H "X-TYPESENSE-API-KEY: ${TYPESENSE_API_KEY}" "${TYPESENSE_ADDRESS}/operations/reset_peers"
```

## create api key

- [docs](https://typesense.org/docs/30.1/api/api-keys.html)

```sh
TYPESENSE_API_KEY=...
TYPESENSE_ADDRESS=...

# ---------------------------------------------------------------------------- #
# list all keys
curl -H "X-TYPESENSE-API-KEY: ${TYPESENSE_API_KEY}" "${TYPESENSE_ADDRESS}/keys"

# ---------------------------------------------------------------------------- #
# create admin key
curl -X POST \
     -H 'Content-Type: application/json' \
     -H "X-TYPESENSE-API-KEY: ${TYPESENSE_API_KEY}" \
     "${TYPESENSE_ADDRESS}/keys" \
     -d '{"description":"Admin key.","actions": ["*"], "collections": ["*"]}'

# ---------------------------------------------------------------------------- #
# create search only key
curl -X POST \
     -H 'Content-Type: application/json' \
     -H "X-TYPESENSE-API-KEY: ${TYPESENSE_API_KEY}" \
     "${TYPESENSE_ADDRESS}/keys" \
     -d '{"description":"Search-only companies key.","actions": ["documents:search"], "collections": ["companies"]}'
```
