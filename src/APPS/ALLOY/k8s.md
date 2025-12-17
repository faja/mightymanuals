# k8s

running as daemonset on a k8s cluster

## mounts

```
/var/log/containers
/var/log/pods
/var/log/journal
/etc/machine-id
```

pod spec copy paste:

```
extraVolumes:
  - name: varlog
    hostPath:
      path: /var/log
  - name: journal
    hostPath:
      path: /var/log/journal
  - name: machine-id
    hostPath:
      path: /etc/machine-id

extraVolumeMounts:
  - name: varlog
    mountPath: /var/log
    readOnly: true
  - name: journal
    mountPath: /var/log/journal
    readOnly: true
  - name: machine-id
    mountPath: /etc/machine-id
    readOnly: true
```

## other pod spec stuff
```
securityContext:
  runAsUser: 0
  runAsGroup: 0
  privileged: false
```

## config

```
// ----------------------
// Kubernetes discovery
// ----------------------
discovery.kubernetes "pods" {
  role = "pod"
}

// ----------------------
// Container logs
// ----------------------
loki.source.kubernetes "containers" {
  targets    = discovery.kubernetes.pods.targets
  forward_to = [loki.process.k8s.receiver]
}

// ----------------------
// Journald logs
// ----------------------
loki.source.journal "systemd" {
  path = "/var/log/journal"

  labels = {
    job = "systemd-journal"
  }

  forward_to = [loki.process.journal.receiver]
}

// ----------------------
// Processing: k8s logs
// ----------------------
loki.process "k8s" {
  stage.match {
    selector = "{__meta_kubernetes_pod_container_name!=\"\"}"
    action  = "keep"
  }

  stage.labels {
    values = {
      namespace = "__meta_kubernetes_namespace",
      pod       = "__meta_kubernetes_pod_name",
      container = "__meta_kubernetes_pod_container_name",
      node      = "__meta_kubernetes_pod_node_name",
    }
  }

  forward_to = [loki.write.default.receiver]
}

// ----------------------
// Processing: journal logs
// ----------------------
loki.process "journal" {
  stage.labels {
    values = {
      node = "__journal__hostname",
      unit = "__journal__systemd_unit",
    }
  }

  forward_to = [loki.write.default.receiver]
}

// ----------------------
// Loki output
// ----------------------
loki.write "default" {
  endpoint {
    url = "https://loki.example.com/loki/api/v1/push"
  }
}
```
