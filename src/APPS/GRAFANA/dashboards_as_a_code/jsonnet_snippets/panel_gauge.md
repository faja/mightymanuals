- simple % clock with threasholds 0-100%
```
local panelClusterPodsAllocation = {
  // type, title and description
  "type": "gauge",
  "title": "Cluster pods allocation %",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(kube_pod_status_phase{phase=\"Running\"})\n  /\nsum(kube_node_status_allocatable{resource=\"pods\"})",
      "instant": true
    }
  ],

  // fieldConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "thresholds"
      },
      "thresholds": {
        "steps": [
          {
            "color": "green",
            "value": null
          },
          {
            "color": "yellow",
            "value": 0.8
          },
          {
            "color": "dark-red",
            "value": 0.9
          }
        ]
      },
      "unit": "percentunit"
    }
  }
};
```
