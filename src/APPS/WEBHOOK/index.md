#

[https://github.com/adnanh/webhook](https://github.com/adnanh/webhook)

in general this is TODO, but here is some my old stuff

- chef `json` hook
```json
[
  {
    "id": "deploy",
    "execute-command": "/var/lib/webhook/scripts/deploy.sh",
    "command-working-directory": "/tmp",
    "include-command-output-in-response": true,
    "include-command-output-in-response-on-error": true,
    "trigger-rule-mismatch-http-response-code": 502,
    "pass-file-to-command": [
      {
        "source": "payload",
        "name": "env",
        "envname": "CHEF_ENV_FILE"
      }
    ],
    "pass-environment-to-command": [
      {
        "envname": "CHEF_ROLES",
        "source": "header",
        "name": "X-Webhook-Context"
      }
    ],
    "trigger-rule": {
      "match": {
        "type": "value",
        "value": "{{ getenv "X_WEBHOOK_TOKEN" }}",
        "parameter":
        {
          "source": "header",
          "name": "X-Webhook-Token"
        }
      }
    }
  }
]
```

- chef `deploy.sh` script
```sh
#!/bin/bash -

set -e

# upload environment file
if test -z "${CHEF_ENV_FILE}"
then
  echo empty CHEF_ENV_FILE environment variable, please check the hook execution
  exit 1
fi
if ! test -f "${CHEF_ENV_FILE}"
then
  echo CHEF_ENV_FILE "${CHEF_ENV_FILE}" does not exist
  exit 1
fi

# roles to execute
if test -z "${CHEF_ROLES}"
then
  echo empty CHEF_ROLES environment variable, please check the hook execution
  exit 1
fi

mv ${CHEF_ENV_FILE} ${CHEF_ENV_FILE}.json
/opt/chef/bin/knife environment from file ${CHEF_ENV_FILE}.json
mv ${CHEF_ENV_FILE}.json ${CHEF_ENV_FILE}

for role in $(echo $CHEF_ROLES | tr ',' '\n')
do
  IPS=$(/opt/chef/bin/knife search node "chef_environment:dev AND role:${role}" -a ipaddress -F json | jq -r '.rows[] | .[].ipaddress')
  for ip in $IPS
  do
    ssh -o "StrictHostKeyChecking no" -o "UserKnownHostsFile /dev/null" ${ip} /bin/chef-client
  done
done
```

- my short and nice `yaml` hook
```yaml
---
- id: kyln
  http-methods: [GET]
  execute-command: /var/lib/webhook/scripts/kyln.sh
  command-working-directory: /var/lib/docker-compose/kyln
  include-command-output-in-response: true
  include-command-output-in-response-on-error: true
  trigger-rule-mismatch-http-response-code: 400
  trigger-rule:
    match:
      type: value
      value: "{{ getenv "X_WEBHOOK_TOKEN" }}"
      parameter:
        source: header
        name: X-Webhook-Token
```
