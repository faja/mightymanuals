- simplest stat ever: single valie, instant query, color value
```
local panelStatefulsetsStatefulsets = {
  // type, title and description
  "type": "stat",
  "title": "Statefulsets",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "count(kube_statefulset_created{namespace=~\"$namespace\"})",
      "instant": true
    }
  ]
};
```

- copy paste example, text from lables
```
local panelVersion = {
  // type, title and description
  "type": "stat",
  "title": "Version",
  "description": "blabla",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "prometheus_build_info{job=\"$job\"}",
      "instant": true,
      "legendFormat": "{{ version }}"
    }
  ],

  // filedConfig
  "fieldConfig": {
  },

  // options
  "options": {
    "textMode": "name",   // display text from label
    "colorMode": "none",  // disable color
    "graphMode": "none",  // disable graphing values (for instant query it does not matter)
    "reduceOptions": {
      "calcs": [
        "lastNotNull"
      ]
    }
  }
};
```

- copy paste example, single value latest, no graph
```
local panelRetention = {
  // type, title and description
  "type": "stat",
  "title": "Retention",
  "description": "blabla...",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "time() - prometheus_tsdb_lowest_timestamp_seconds{job=\"$job\"}",
      "instant": true
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "unit": "s"
    }
  },

  // options
  "options": {
    "colorMode": "none",  // disable color
    "graphMode": "none",  // disable graphing
    "reduceOptions": {
      "calcs": [
        "lastNotNull"
      ]
    }
  }
};
```

- copy paste example, single value latest + graph
```
local panelStorageSize = {
  // type, title and description
  "type": "stat",
  "title": "Storage size",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "prometheus_tsdb_storage_blocks_bytes{job=\"$job\"}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "light-red",
        "mode": "fixed"
      },
      "unit": "bytes"
    }
  },

  // options
  "options": {
    "colorMode": "none",  // disable color
    "reduceOptions": {
      "calcs": [
        "lastNotNull"
      ]
    }
  }
};
```

- single stat, avare value across all metrics
```
// INFO
// the way to do it is:
//   - use transformation reduce (calculation does not matter)
//   - use options.reduceOptions.calcs: mean (this calculates avarerage)

local panelJobsAvgDuration = {
  // type, title and description
  "type": "stat",
  "title": "Avg duration",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "kube_job_status_completion_time{namespace=~\"$namespace\"} - kube_job_status_start_time{namespace=~\"$namespace\"}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "unit": "s"
    }
  },

  // options
  "options": {
    "reduceOptions": {
      "calcs": [
        "mean"
      ]
    }
  },

  // transformations
  "transformations": [
    {
      "id": "reduce"
    }
  ]
};
```

- single stat, merge multiple values into one single stat, for instance for displaying a version
```
    local panelClusterVersion = {
  // type, title and description
  "type": "stat",
  "title": "Cluster version",
  "description": "Actually a `kubelet` version running on a node, selected by `Last*`.",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "kube_node_info",
      "instant": true,
      "legendFormat": "{{ kubelet_version }}"
    }
  ],

  // filedConfig
  "fieldConfig": {
  },

  // options
  "options": {
    "textMode": "name",   // display text from label
    "colorMode": "none",  // disable color
    "reduceOptions": {
      "calcs": [
        "lastNotNull"
      ]
    }
  },

  // transformations
  "transformations": [
    {
      "id": "merge",
      "options": {}
    },
    {
      "id": "renameByRegex",
      "options": {
        "regex": "v([^-]+)-.+",
        "renamePattern": "$1"
      }
    }
  ]
};
```
