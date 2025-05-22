---

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
