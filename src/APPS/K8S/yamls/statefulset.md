# concepts
# yaml snippets

- `serviceName` and `selector`
```yaml
# serviceName - service name that is mapped to this statefulset
#               service should exist and should be headless (clusterIP: None)
#               service provides the following DNS names for the pods:
#               podName-${index}.serviceName.namespace.svc.cluster.local, eg:
#               typesense-0.typesense.typesense.svc.cluster.local
# selector    - how to match pods for this specific statefulset
spec:
  serviceName: typesense
  selector:
    matchLabels:
      app.kubernetes.io/name: typesense
      app.kubernetes.io/instance: typesense
```

- `updateStrategy` and `podManagementPolicy`
```yaml
# podManagementPolicy - is about inital deployment and scaling
#                       and this can happen 1 by 1 (OrderedReady - default)
#                       or all at once (Parallel)
# updateStrategy      - is about updating, and with maxUnavailable set to 1
#                       this is done 1 at a time (eg: 2 -> 1 -> 0)
spec:
  podManagementPolicy: Parallel # OrderedReady or Parallel
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
```

- `replicas` and `revisionHistoryLimit`
```yaml
spec:
  replicas: 3
  revisionHistoryLimit: 3
```

- `persistentVolumeClaimRetentionPolicy`
```yaml
# what to do with pvc and pv when statefulset is deleted or scaled down
# NOTE: the behaviour also depends on storageClass ReclaimPolicy
#       kubectl describe storageClass ${NAME}
spec:
  persistentVolumeClaimRetentionPolicy:
    whenDeleted: Retain # Retain(default), Delete
    whenScaled: Retain  # Retain(default), Delete
```
