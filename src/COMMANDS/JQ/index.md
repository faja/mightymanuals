# quick ones

```sh
yq -r '. | .apiVersion + " " + .kind'  # print two fields at once
jq -S . some.json  # sort keys !!!
jq -e -r ...       # -e fails if item is not found
```


---

OLD TODO:



www: http://stedolan.github.io/jq/

binary: ~/Dropbox/manuals/APPS/CHEF/ds-chef/chef/cookbooks/sysadmin/files/default/jjq


      $ jjq '.' spec.json
      $ jjq '. | keys' spec.json
      $ jjq '.balance | keys' spec.json



jjq -c "{source: .source_id, bucketid: .rome.fwd}"


## examples
jesli mamy liste i w kazdym elemencie mamy np. Name, i chcemy wyswietlic Name to:
  jq '.Images[] | .Name' plik
  jq '.Images[] | {name: .Name, creationDate: .CreationDate}' /tmp/voluumdb-prod.ami.info

## dash in key name
    jq nie supportuje - w nazwie klucza - traktuje go jako substaction

    % jq '.security_group_voluum-cassandra-mc' /tmp/a.json
    jq: error: cassandra/0 is not defined at <top-level>, line 1:
    .security_group_voluum-cassandra-mc
    jq: error: mc/0 is not defined at <top-level>, line 1:
    .security_group_voluum-cassandra-mc
    jq: 2 compile errors

    workaround do tego:
    jq '.["security_group_voluum-cassandra-mc"]' /tmp/a.json



## raw data
    jq -r

## delete an element from the json
```
cat t.json | jq 'del(.default_attributes.pmizer.stacks.dev)'
```

## add/merge (deep merge)
```
jq -s '.[0] * .[1]' t.json t2.json
```

## list to string with new line
knife search node 'role:base' -F json -i | jq -r '.rows[]'

##  move THE WHOLE json into a single TOP LEVEL KEY (in this example "env" key)
jq '. as $all | del(.) | .env = $all'  test.json

## pass env variable to jq query
    ```
    COOKBOOK=asdocker
    jq -r --arg cookbook ${COOKBOOK} '.cookbook_versions[$cookbook]' environments/prd.json
    ```

## select "subkey" from list of objects
- file.json:
    ```
      {
        "results": 3,
        "rows": [
          {
            "node01.amsdard.io": {
              "ipaddress": "172.30.120.15"
            }
          },
          {
            "node03.amsdard.io": {
              "ipaddress": "172.30.174.27"
            }
          },
          {
            "bastion.amsdard.io": {
              "ipaddress": "172.30.16.182"
            }
          }
        ]
      }
    ```
- command: `jq -r '.rows[] | .[] | .ipaddress' file.json`

## JQ_DIFF
```
#!/bin/bash -

ENV=prd
ROLES=

KEYS=$(git show "HEAD:chef/environments/${ENV}.json" | jq -r '.default_attributes | keys[]')
for KEY in ${KEYS}
do
  if ! diff -q \
    <(git show "HEAD:chef/environments/${ENV}.json" | jq -r --arg key ${KEY} '.default_attributes[$key]') \
    <(git show "HEAD^:chef/environments/${ENV}.json" | jq -r --arg key ${KEY} '.default_attributes[$key]') \
    > /dev/null
  then
    ROLES=${ROLES},${KEY}
  fi
done

ROLES=$(echo ${ROLES} | sed 's/^,//')
echo X-Hook-Context: ${ROLES}
```

## replace the whole json with another, but keep one key, in this case `id`
```
jq -s '.[0].id as $id | .[2].id = $id | .[2] * .[1]' ori.json new.json
```

## JQ if filed == value

```
jq '.[] | select(.key == "value")'
```

eg:
```
virsh qemu-agent-command ${1} '{"execute":"guest-network-get-interfaces"}' |

  jq -r '.return[] |                           # lets get all the results
      select(.name == "eth0") |                # find interface "eth0"
      .["ip-addresses"][] |                    # get all ip-addresses
      select(.["ip-address-type"] == "ipv4") | # find the one with type "ipv4"
      .["ip-address"]'                         # finally get the ip address field
```
