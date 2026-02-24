# concepts
# yaml snippets

## scheduling
- security (`securityContext`)
```yaml
spec:
  securityContext:
    fsGroup: 99 # this is for volume mounts
  containers:
    - name: haproxy
      securityContext:
        runAsNonRoot: true
        runAsUser: 99
        readOnlyRootFilesystem: true
        allowPrivilegeEscalation: false
        capabilities:
          drop: ["ALL"]
        seccompProfile:
          type: RuntimeDefault
```

- simple but working stuff: `nodeName`, `nodeSelector`
```yaml
# nodeName     - this is reall "run this pod on exactly this node"
# nodeSelector - schedule a pod on a node with particular label

spec:
  nodeSelector: worker-1

spec:
  nodeSelector:
    topology.kubernetes.io/zone: eu-central-1a
```

- `affinity`: schedule on nodes with label maching one of the values
```yaml
# run pod in eu-central-1a or eu-central-1b
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: topology.kubernetes.io/zone
            operator: In
            values:
              - eu-central-1a
              - eu-central-1b
```

- `affinity`: do not schedule on nodes if `topology.kubernetes.io/zone` is missing or `topology.kubernetes.io/zone == eu-central-1b`
```yaml
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: topology.kubernetes.io/zone
            operator: Exists
          - key: topology.kubernetes.io/zone
            operator: NotIn
            values:
              - eu-central-1b
```
