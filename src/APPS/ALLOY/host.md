# host with containerss

## mounts
```
# containers
- /var/lib/docker/containers:/var/lib/docker/containers:ro
# journal
- /etc/machine-id:/etc/machine-id:ro
- /var/log/journal:/var/log/journal:ro
- /run/log/journal:/run/log/journal:ro
```

## config

```
// containers
local.file_match "containers" {
        path_targets = [{
                __path__    = "/var/lib/docker/containers/*/*log",
                job         = "containers",
        }]
}

loki.source.file "containers" {
        targets               = local.file_match.containers.targets
        forward_to            = [loki.process.containers.receiver]
        legacy_positions_file = "/var/lib/promtail/positions.yaml"
}

loki.process "containers" {
        forward_to = [loki.write.default.receiver]

        stage.json {
                expressions = {
                        attrs     = "attrs",
                        output    = "log",
                        timestamp = "time",
                }
        }

        stage.json {
                expressions = {
                        container = "tag",
                        stack     = "stack",
                        image_tag = "image_tag",
                }
                source = "attrs"
        }

        stage.labels {
                values = {
                        container = "container",
                        stack     = "stack",
                }
        }

        stage.structured_metadata {
                values = {
                        image_tag = "image_tag",
                }
        }

        stage.label_drop {
                values = ["filename", "service_name"]
        }

        stage.timestamp {
                source = "timestamp"
                format = "RFC3339Nano"
        }

        stage.output {
                source = "output"
        }
}

// journal
discovery.relabel "journal" {
        targets = []

        rule {
                source_labels = ["__journal__systemd_unit"]
                target_label  = "unit"
        }

        rule {
                source_labels = ["unit"]
                regex         = "^session-\\d+\\.scope"
                target_label  = "unit"
                replacement   = "session.scope"
        }
}

loki.source.journal "journal" {
        max_age       = "6h0m0s"
        relabel_rules = discovery.relabel.journal.rules
        forward_to    = [loki.write.default.receiver]
        labels        = {
                job = "journal",
        }
}

{# TODO: imporve loki service discovery #}
{% for host in groups["infra"] %}
loki.write "default" {
        endpoint {
                url = "http://{{ hostvars[host].ansible_default_ipv4.address }}:3100/loki/api/v1/push"
        }
        external_labels = {
                nodename = "{{ ansible_nodename }}",
        }
}
{% endfor %}
```

## example compose.yaml
```
---
name: alloy

networks:
  alloy:
    name: alloy

services:
  alloy:
    container_name: alloy
    image: {{ alloy_image_name }}:{{ alloy_image_tag }}
    restart: unless-stopped
    user: root:root # must be root to access container logs
    # default entrypoint: ENTRYPOINT ["/bin/alloy"]
    # default command:    CMD ["run" "/etc/alloy/config.alloy" "--storage.path=/var/lib/alloy/data"]
    networks:
      - alloy
    volumes:
      # config and storage path
      - /etc/localtime:/etc/localtime:ro
      - /etc/alloy/:/etc/alloy/:ro
      - /var/lib/alloy:/var/lib/alloy:rw
      {% if alloy_mount_promtail_data_path %}
      # promtail data path for migration purposes
      - /var/lib/promtail:/var/lib/promtail:rw
      {% endif  %}
      # containers
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
      # journal
      - /etc/machine-id:/etc/machine-id:ro
      - /var/log/journal:/var/log/journal:ro
      - /run/log/journal:/run/log/journal:ro
      {# TODO: /var/log
      # /var/log
      - /var/log:/var/log:ro
      #}
    {# TODO: ports
    ports:
      - 0.0.0.0:{{ alloy_port }}:{{ alloy_port }}/tcp
    #}
    logging:
      options:
        tag: "{{ "{{ .Name }}" }}"
        labels: stack,image_tag
    labels:
      stack: alloy
      image_tag: {{ alloy_image_tag }}``yaml

```
