---

- [official ConfigMap reference](https://kubernetes.io/docs/reference/kubernetes-api/config-and-storage-resources/config-map-v1/)

# tldr
```yaml
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Values.name }}
data:
  mapping-config.yaml: | {{ toYaml .Values.mappingConfig | nindent 4 }}
```

# trix
- include multi line string as a config file
```yaml
data:
    config.yaml: | {{ ... | nindent 4 }}
# or
data:
    config.yaml: |
      {{- ... | nindent 4 }}
```

- include "plain" file
```yaml
data:
    haproxy.cfg: | {{ .Files.Get "files/haproxy.cfg" | nindent 4 }}
```
- include "template" file
```yaml
data:
    haproxy.cfg: | {{ tpl (.Files.Get "files/haproxy.cfg.tpl") . | nindent 4 }}
```

- include multiline yaml from values
```yaml
data:
  mapping-config.yaml: | {{ toYaml .Values.mappingConfig | nindent 4 }}
```

- provide a config file from outside the chart, "deployment specific",
  NOTE: this is in general not a good practise
```yaml
# first in values.yaml
configYaml: ""

# configmap.yaml
data:
    config.yaml: | {{ tpl .Values.configYaml . | nindent 4 }}
    # or just {{ .Values.configYaml | nindent 4 }} - if no templating is needed

# then run helm with --set-file option, eg:
helm template ... --set-file configYaml=my_custom_config_from_outside_chart.yaml
```
