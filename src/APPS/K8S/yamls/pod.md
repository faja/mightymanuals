#

- schedule on nodes with label topology.kubernetes.io/zone == eu-central-1a
```yaml
spec:
  template:
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
```

- do not schedule on nodes if `topology.kubernetes.io/zone is missing or topology.kubernetes.io/zone == eu-central-1b
```yaml
spec:
  template:
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
