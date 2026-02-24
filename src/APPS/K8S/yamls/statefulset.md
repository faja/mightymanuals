# concepts
# yaml snippets

- `updateStrategy` and `podManagementPolicy`
```yaml
# podManagementPolicy - is about inital deployment and scaling
#                       and this can happen 1 by 1 (OrderedReady - default)
#                       or all at once (Parallel)
# updateStrategy      - is about updating, and with maxUnavailable set to 1
#                       this is done 1 at a time (eg: 2 -> 1 -> 0)
spec:
  template:
    spec:
      podManagementPolicy: Parallel # OrderedReady or Parallel
      updateStrategy:
        type: RollingUpdate
        rollingUpdate:
          maxUnavailable: 1
```
