local grafana = import 'grafonnet/grafana.libsonnet';

local dashboard = grafana.dashboard.new(
  'K8S / Cluster (kubce-state-metrics)',
  timezone='utc',
  time_from='now-2h',
  editable=false,
);

// {{{ dashboard variables/templates
local varPrometheusDS = grafana.template.datasource(
  'PROMETHEUS_DS',     // name
  'prometheus',        // query
  'prometheus',        // current
  hide=true,           // ''      - disables hiding at all, everything is displayed
                       // 'label' - hide the name of the variable, and the drop down is displayed
                       // any other value - hides everything
  //regex='/prometheus/',
);

local varNamespace = std.mergePatch(
  grafana.template.new(
    'namespace',                                       // name
    {"type": "prometheus", "uid": "${PROMETHEUS_DS}"}, // datasource
    "label_values(kube_namespace_created, namespace)", // query
    includeAll=true,
    current='all',
  ),
  {
    "definition": "label_values(kube_namespace_created, namespace)",
  }
);
// }}}

// {{{ panels
// {{{ row: Cluster
// {{{ panel: Cluster version
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
// }}}
// {{{ panel: Number of nodes
local panelNumberOfNodes = {
  // type, title and description
  "type": "stat",
  "title": "Number of nodes",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(kube_node_info)",
      "instant": true,
    }
  ],

  // filedConfig
  "fieldConfig": {
  },

  // options
  "options": {
    "reduceOptions": {
      "calcs": [
        "lastNotNull"
      ]
    }
  }
};
// }}}
// {{{ panel: Oldest node age
local panelOldestNodeAge = {
  // type, title and description
  "type": "stat",
  "title": "Oldest node age",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "time() - min(kube_node_created)",
      "instant": true
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "orange",
        "mode": "fixed"
      },
      "decimals": 2,
      "unit": "s"
    }
  },

  // options
  "options": {
    "reduceOptions": {
      "calcs": [
        "lastNotNull"
      ]
    }
  }
};
// }}}
// {{{ panel: Newest node age
local panelNewestNodeAge = {
  // type, title and description
  "type": "stat",
  "title": "Newest node age",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "time() - max(kube_node_created)",
      "instant": true
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "blue",
        "mode": "fixed"
      },
      "decimals": 2,
      "unit": "s"
    }
  },

  // options
  "options": {
    "reduceOptions": {
      "calcs": [
        "lastNotNull"
      ]
    }
  }
};
// }}}
// {{{ panel: Nodes unschedulable
local panelNodesUnschedulable = {
  // type, title and description
  "type": "stat",
  "title": "Nodes unschedulable",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(kube_node_spec_unschedulable)",
      "instant": true
    }
  ],

  // filedConfig
  "fieldConfig": {
  },

  // options
  "options": {
    "reduceOptions": {
      "calcs": [
        "lastNotNull"
      ]
    }
  }
};
// }}}
// {{{ panel: Nodes bad condition
local panelNodesBadCondition = {
  // type, title and description
  "type": "stat",
  "title": "Nodes bad condition",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "kube_node_status_condition{condition=\"Ready\", status!=\"true\"} > 0",
      "instant": true,
      "legendFormat": "{{node}} - NotReady",
    },
    {
      "expr": "kube_node_status_condition{condition!=\"Ready\", status!=\"false\"} > 0",
      "instant": true,
      "legendFormat": "{{node}} - {{condition}}",
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "red",
        "mode": "fixed"
      },
    }
  },

  // options
  "options": {
    "textMode": "name",       // display text from label
    "justifyMode": "center",
    "reduceOptions": {
      "calcs": [
        "lastNotNull"
      ]
    }
  }
};
// }}}

// {{{ panel: Cluster pods allocation %
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
// }}}
// {{{ panel: Cluster cpu requested %
local panelClusterCpuRequested = {
  // type, title and description
  "type": "gauge",
  "title": "Cluster cpu requested %",
  "description": "Based on CPUs requests",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(kube_pod_container_resource_requests{resource=\"cpu\"})\n  /\nsum(kube_node_status_allocatable{resource=\"cpu\"})",
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
// }}}
// {{{ panel: Cluster memory requested %
local panelClusterMemoryRequested = {
  // type, title and description
  "type": "gauge",
  "title": "Cluster memory requested %",
  "description": "Based on memory requests",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(kube_pod_container_resource_requests{resource=\"memory\"})\n  /\nsum(kube_node_status_allocatable{resource=\"memory\"})",
      "instant": true,
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
// }}}

// {{{ panel: Cluster pods
local panelClusterPods = {
  // title and type
  "type": "timeseries",
  "title": "Cluster pods",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(kube_pod_status_phase{phase=\"Running\"})",
      "legendFormat": "running"
    },
    {
      "expr": "sum(kube_node_status_allocatable{resource=\"pods\"})",
      "legendFormat": "max"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "light-green",
        "mode": "fixed"
      },
      "custom": {
        "fillOpacity": 10,
      },
      "unit": "short"
    },
    "overrides": [
      {
        "matcher": {
          "id": "byName",
          "options": "max"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "super-light-red",
              "mode": "fixed"
            }
          }
        ]
      }
    ]
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panel: Cluster cpu
local panelClusterCpu = {
  // title and type
  "type": "timeseries",
  "title": "Cluster cpu",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(kube_node_status_allocatable{resource=\"cpu\"})",
      "legendFormat": "max"
    },
    {
      "expr": "sum(kube_pod_container_resource_requests{resource=\"cpu\"})",
      "legendFormat": "requests"
    },
    {
      "expr": "sum(kube_pod_container_resource_limits{resource=\"cpu\"})",
      "legendFormat": "limits"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "light-green",
        "mode": "fixed"
      },
      "custom": {
        "fillOpacity": 10,
      },
      "unit": "none"
    },
    "overrides": [
      {
        "matcher": {
          "id": "byName",
          "options": "max"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "super-light-red",
              "mode": "fixed"
            }
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "limits"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "light-purple",
              "mode": "fixed"
            }
          }
        ]
      }
    ]
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panel: Cluster memory
local panelClusterMemory = {
  // title and type
  "type": "timeseries",
  "title": "Cluster memory",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(kube_node_status_allocatable{resource=\"memory\"})",
      "legendFormat": "max"
    },
    {
      "expr": "sum(kube_pod_container_resource_requests{resource=\"memory\"})",
      "legendFormat": "requests"
    },
    {
      "expr": "sum(kube_pod_container_resource_limits{resource=\"memory\"})",
      "legendFormat": "limits"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "light-green",
        "mode": "fixed"
      },
      "custom": {
        "fillOpacity": 10,
      },
      "unit": "bytes"
    },
    "overrides": [
      {
        "matcher": {
          "id": "byName",
          "options": "max"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "super-light-red",
              "mode": "fixed"
            }
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "limits"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "light-purple",
              "mode": "fixed"
            }
          }
        ]
      }
    ]
  },

  // options
  "options": {
  }
};
// }}}
// }}}
// {{{ row: Cluster CPU and Memory
// {{{ panel: CPU % busy
local panelCPUPercentBusy = {
  // title and type
  "type": "timeseries",
  "title": "CPU % busy",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "100 -\n  (avg by (nodename) (rate(node_cpu_seconds_total{mode=\"idle\"}[$__rate_interval])) * 100)",
      "legendFormat": "{{ nodename }}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 11,
      },
      "max": 100,
      "min": 0,
      "unit": "percent"
    }
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panel: Memory % used
local panelMemoryPercentUsed = {
  // title and type
  "type": "timeseries",
  "title": "Memory % used",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "#\n#  (100 * used) / total = %used\n#\n\n100 * (\n  node_memory_MemTotal_bytes{} - (\n    node_memory_MemFree_bytes{} + \n    node_memory_Cached_bytes{} +\n    node_memory_Buffers_bytes{}\n  ) # used memory\n)\n  /\nnode_memory_MemTotal_bytes{} # total",
      "legendFormat": "{{ nodename }}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 10,
      },
      "max": 100,
      "min": 0,
      "unit": "percent"
    }
  },

  // options
  "options": {
  }
};
// }}}
// }}}
// {{{ row: Pods
// {{{ panel: Oldest pod age
local panelPodsOldest = {
  // type, title and description
  "type": "stat",
  "title": "Oldest pod age",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "time() - min(kube_pod_created{namespace=~\"$namespace\"})",
      "instant": true
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "orange",
        "mode": "fixed"
      },
      "decimals": 2,
      "unit": "s"
    }
  },
};
// }}}
// {{{ panel: Newest pod age 
local panelPodsNewest = {
  // type, title and description
  "type": "stat",
  "title": "Newest pod age",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "time() - max(kube_pod_created{namespace=~\"$namespace\"})",
      "instant": true
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "blue",
        "mode": "fixed"
      },
      "decimals": 0,
      "unit": "s"
    }
  }
};
// }}}
// {{{ panel: Pods running 
local panelPodsPodsRunning = {
  // type, title and description
  "type": "stat",
  "title": "Pods running",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(kube_pod_status_phase{namespace=~\"$namespace\", phase=\"Running\"})",
      "instant": true
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "purple",
        "mode": "fixed"
      },
      "decimals": 0,
      "unit": "none"
    }
  }
};
// }}}
// {{{ panel: New pods in last 30 minutes 
local panelPodsNewIn30Mins = {
  // type, title and description
  "type": "stat",
  "title": "New pods in last 30 minutes",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "count(time() - kube_pod_start_time{namespace=~\"$namespace\"} < 1800)",
      "instant": true
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "purple",
        "mode": "fixed"
      },
      "decimals": 0,
      "unit": "none"
    }
  }
};
// }}}
// {{{ panel: Pods pending
local panelPodsPodsPending = {
  // type, title and description
  "type": "stat",
  "title": "Pods pending",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(kube_pod_status_phase{namespace=~\"$namespace\", phase=\"Pending\"})",
      "instant": true
    }
  ],

  // fieldConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "thresholds"
      },
      "decimals": 0,
      "thresholds": {
        "steps": [
          {
            "color": "green"
          },
          {
            "color": "red",
            "value": 1
          }
        ]
      },
      "unit": "none"
    }
  }
};
// }}}
// {{{ panel: Pods failed
local panelPodsPodsFailed = {
  // type, title and description
  "type": "stat",
  "title": "Pods failed",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(kube_pod_status_phase{namespace=~\"$namespace\", phase=\"Failed\"})",
      "instant": true
    }
  ],

  // fieldConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "thresholds"
      },
      "decimals": 0,
      "thresholds": {
        "steps": [
          {
            "color": "green"
          },
          {
            "color": "red",
            "value": 1
          }
        ]
      },
      "unit": "none"
    }
  }
};
// }}}
// {{{ panel: Pods
local panelPodsPods = {
  // type, title and description
  "type": "timeseries",
  "title": "Pods",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum by (phase) (kube_pod_status_phase{namespace=~\"$namespace\"})",
      "legendFormat": "{{phase}}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 10,
      },
      "unit": "short"
    }
  },

  // options
  "options": {
  },
};
// }}}
// {{{ panel: Container restarts
local panelPodsContainerRestarts = {
  // type, title and description
  "type": "stat",
  "title": "Container restarts",
  "description": "Container restarts that happened in selected time range",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(increase(kube_pod_container_status_restarts_total{namespace=~\"$namespace\"}[$__range]))",
      "legendFormat": "{{pod}} - {{container}}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "thresholds"
      },
      "decimals": 0,
      "thresholds": {
        "steps": [
          {
            "color": "green"
          },
          {
            "color": "red",
            "value": 5
          }
        ]
      },
      "unit": "none"
    }
  },

  "options": {
    "graphMode": "none",
  }
};
// }}}
// {{{ panel: Containers waiting 
local panelPodsContainersWaiting = {
  // type, title and description
  "type": "stat",
  "title": "Containers waiting",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(kube_pod_container_status_waiting{namespace=~\"$namespace\"})",
      "legendFormat": "{{pod}} - {{container}}",
      "instant": true
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "thresholds"
      },
      "decimals": 0,
      "thresholds": {
        "steps": [
          {
            "color": "green"
          },
          {
            "color": "#EAB839",
            "value": 1
          },
          {
            "color": "red",
            "value": 5
          }
        ]
      },
      "unit": "none"
    }
  }
};
// }}}
// {{{ panel: CPU requested
local panelPodsCPURequested = {
  // type, title and description
  "type": "stat",
  "title": "CPU requested",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(kube_pod_container_resource_requests{namespace=~\"$namespace\", resource=\"cpu\"})",
      "instant": true
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "fixed"
      },
      "unit": "vCPU"
    }
  }
};
// }}}
// {{{ panel: Memory requested
local panelPodsMemoryRequested = {
  // type, title and description
  "type": "stat",
  "title": "Memory requested",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(kube_pod_container_resource_requests{namespace=~\"$namespace\", resource=\"memory\"})",
      "instant": true
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "fixed"
      },
      "unit": "bytes"
    }
  }
};
// }}}
// {{{ panel: Containers in error state 
local panelPodsContainersError = {
  // type, title and description
  "type": "timeseries",
  "title": "Containers in error state",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "kube_pod_container_status_waiting_reason{namespace=~\"$namespace\", reason!=\"ContainerCreating\"} > 0 ",
      "legendFormat": "{{pod}} : {{reason}}"
    },
    {
      "expr": "kube_pod_init_container_status_waiting_reason{namespace=~\"$namespace\", reason!=\"ContainerCreating\"} > 0",
      "legendFormat": "{{pod}} (init) : {{reason}}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 10,
      },
      "min": 0,
      "unit": "short"
    }
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panel: Containers terminated
local panelPodsContainersTerminated = {
  // type, title and description
  "type": "timeseries",
  "title": "Containers terminated",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "kube_pod_container_status_terminated_reason{namespace=~\"$namespace\", reason!=\"Completed\"} > 0 ",
      "legendFormat": "{{pod}} : {{reason}}"
    },
    {
      "expr": "kube_pod_init_container_status_terminated_reason{namespace=~\"$namespace\", reason!=\"Completed\"} > 0",
      "legendFormat": "{{pod}} (init) : {{reason}}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 10,
      },
      "unit": "short"
    }
  },

  // options
  "options": {
  }
};
// }}}
// }}}
// {{{ row: Daemonsets
// {{{ panel: Daemonsets
local panelDaemonsetsDaemonsets = {
  // type, title and description
  "type": "stat",
  "title": "Daemonsets",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "count(kube_daemonset_created{namespace=~\"$namespace\"})",
      "instant": true
    }
  ]
};
// }}}
// {{{ panel: Daemonsets pods
local panelDaemonsetsPods = {
  // type, title and description
  "type": "stat",
  "title": "Daemonsets pods",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(kube_daemonset_status_number_ready{namespace=~\"$namespace\"})",
      "instant": true
    }
  ]
};
// }}}
// {{{ panel: Daemonsets unavailable
local panelDaemonsetsUnavailable = {
  // type, title and description
  "type": "table",
  "title": "Daemonsets unavailable",
  "description": "The number of nodes that should be running the daemon pod and have none of the daemon pod running and available.\n\n0 is GOOD:)",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "kube_daemonset_status_number_unavailable{namespace=~\"$namespace\"}",
      "legendFormat": "{{ daemonset }} ({{ namespace }})",
      "instant": true
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "custom": {
        "displayMode": "color-background"
      },
      "thresholds": {
        "steps": [
          {
            "color": "green"
          },
          {
            "color": "red",
            "value": 1
          }
        ]
      }
    },
  },

  // options
  "options": {
    "showHeader": false
  },

  // transformations
  "transformations": [
    {
      "id": "reduce"
    }
  ]
};
// }}}
// }}}
// {{{ row: Deployments
// {{{ panel: Deployments
local panelDeploymentsDeployments = {
  // type, title and description
  "type": "stat",
  "title": "Deployments",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "count(kube_deployment_created{namespace=~\"$namespace\"})",
      "instant": true
    }
  ]
};
// }}}
// {{{ panel: Replicas
local panelDeploymentsReplicas = {
  // type, title and description
  "type": "stat",
  "title": "Replicas",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(kube_deployment_spec_replicas{namespace=~\"$namespace\"})",
      "instant": true
    }
  ]
};
// }}}
// {{{ panel: Replicas ready
local panelDeploymentsReplicasReady = {
  // type, title and description
  "type": "stat",
  "title": "Replicas ready",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(kube_deployment_status_replicas_available{namespace=~\"$namespace\"})",
      "instant": true
    }
  ],
};
// }}}
// {{{ panel: Replicas(timeseries)
local panelDeploymentsReplicasTS = {
  // type, title and description
  "type": "timeseries",
  "title": "Replicas",
  "description": "where:\n- spec - number of pod replicas defined in deployment yaml definition\n- current - number of pod replicas currently running\n- available - number of pod replicas that passing `readiness` probe (if specified)",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(kube_deployment_spec_replicas{namespace=~\"$namespace\"})",
      "legendFormat": "spec"
    },
    {
      "expr": "sum(kube_deployment_status_replicas{namespace=~\"$namespace\"})",
      "legendFormat": "current"
    },
    {
      "expr": "sum(kube_deployment_status_replicas_available{namespace=~\"$namespace\"})",
      "legendFormat": "available"
    },
    {
      "expr": "sum(kube_deployment_status_replicas_unavailable{namespace=~\"$namespace\"})",
      "legendFormat": "unavailable"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 10
      },
      "unit": "short"
    }
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panel: Missing replicas
local panelDeploymentsMissing = {
  // type, title and description
  "type": "table",
  "title": "Missing replicas",
  "description": "How many pods should be running but they are not.\n\n0 is GOOD!",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "kube_deployment_status_replicas_unavailable{namespace=~\"$namespace\"}",
      "legendFormat": "{{ deployment }} ({{ namespace }})",
      "instant": true
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "custom": {
        "displayMode": "color-background"
      },
      "thresholds": {
        "steps": [
          {
            "color": "green"
          },
          {
            "color": "red",
            "value": 1
          }
        ]
      }
    },
  },

  // options
  "options": {
    "showHeader": false
  },

  // transformations
  "transformations": [
    {
      "id": "reduce"
    }
  ]
};
// }}}
// }}}
// {{{ row: Statefulsets
// {{{ panel: Statefulsets
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
// }}}
// {{{ panel: Replicas
local panelStatefulsetsReplicas = {
  // type, title and description
  "type": "stat",
  "title": "Replicas",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(kube_statefulset_replicas{namespace=~\"$namespace\"})",
      "instant": true
    }
  ],

};
// }}}
// {{{ panel: Replicas ready
local panelStatefulsetsReplicasReady = {
  // type, title and description
  "type": "stat",
  "title": "Replicas ready",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(kube_statefulset_status_replicas_ready{namespace=~\"$namespace\"})",
      "instant": true
    }
  ]
};
// }}}
// {{{ panel: Replicas ready (timeseries)
local panelStatefulsetsReplicasReadyTS = {
  // type, title and description
  "type": "timeseries",
  "title": "Replicas ready",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "kube_statefulset_status_replicas_ready{namespace=~\"$namespace\"}",
      "legendFormat": "{{ statefulset }}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 10
      },
      "unit": "short"
    }
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panel: Missing replicas
local panelStatefulsetsMissing = {
  // type, title and description
  "type": "table",
  "title": "Missing replicas",
  "description": "How many pods should be running but are not.\n\n0 is GOOD!",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "kube_statefulset_status_replicas{namespace=~\"$namespace\"} - kube_statefulset_status_replicas_ready{namespace=~\"$namespace\"}",
      "legendFormat": "{{ statefulset }} ({{ namespace }})",
      "instant": true
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "custom": {
        "displayMode": "color-background"
      },
      "thresholds": {
        "steps": [
          {
            "color": "green"
          },
          {
            "color": "red",
            "value": 1
          }
        ]
      }
    },
  },

  // options
  "options": {
    "showHeader": false
  },

  // transformations
  "transformations": [
    {
      "id": "reduce"
    }
  ]
};
// }}}
// }}}
// {{{ row: Jobs
// {{{ panel: Cronjobs
local panelJobsCronJobs = {
  // type, title and description
  "type": "stat",
  "title": "Cronjobs",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "count(kube_cronjob_created{namespace=~\"$namespace\"})"
    }
  ]
};
// }}}
// {{{ panel: Jobs
local panelJobsJobs = {
  // type, title and description
  "type": "stat",
  "title": "Jobs",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(kube_job_info{namespace=~\"$namespace\"})"
    }
  ]
};
// }}}

// {{{ panel: Jobs active
local panelJobsJobsActive = {
  // type, title and description
  "type": "stat",
  "title": "Jobs active",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(kube_job_status_active{namespace=~\"$namespace\"})"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "blue",
        "mode": "fixed"
      }
    }
  }
};
// }}}
// {{{ panel: Jobs succeeded
local panelJobsJobsSucceeded = {
  // type, title and description
  "type": "stat",
  "title": "Jobs succeeded",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(kube_job_status_succeeded{namespace=~\"$namespace\"})"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "blue",
        "mode": "fixed"
      }
    }
  }
};
// }}}
// {{{ panel: Jobs failed
local panelJobsJobsFailed = {
  // type, title and description
  "type": "stat",
  "title": "Jobs failed",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(kube_job_status_failed{namespace=~\"$namespace\"})"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "blue",
        "mode": "fixed"
      }
    }
  }
};
// }}}

// {{{ panel: Cronjobs last schedule
local panelJobsLastSchedule= {
  // type, title and description
  "type": "table",
  "title": "Cronjobs last schedule",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "time() - kube_cronjob_status_last_schedule_time{namespace=~\"$namespace\"}",
      "legendFormat": "{{ cronjob }} (ns: {{namespace }})",
      "instant": true
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "decimals": 2,
      "unit": "s"
    }
  },

  // options
  "options": {
    "showHeader": false,
    "sortBy": [
      {
        "desc": false,
        "displayName": "Max"
      }
    ]
  },

  // transformations
  "transformations": [
    {
      "id": "reduce"
    }
  ]
};
// }}}
// {{{ panel: Cronjobs next schedule
local panelJobsNextSchedule = {
  // type, title and description
  "type": "table",
  "title": "Cronjobs next schedule",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "kube_cronjob_next_schedule_time{namespace=~\"$namespace\"} - time()",
      "legendFormat": "{{ cronjob }} (ns: {{namespace }})",
      "instant": true
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "decimals": 2,
      "unit": "s"
    }
  },

  // options
  "options": {
    "showHeader": false,
    "sortBy": [
      {
        "desc": false,
        "displayName": "Max"
      }
    ]
  },

  // transformations
  "transformations": [
    {
      "id": "reduce"
    }
  ]
};
// }}}

// {{{ panel: Failed jobs
local panelJobsFailedJobs = {
  // type, title and description
  "type": "table",
  "title": "Failed jobs",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "kube_job_status_failed{namespace=~\"$namespace\"}==1",
      "legendFormat": "{{ job_name }} (ns: {{ namespace }})",
      "instant": true
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "red",
        "mode": "fixed"
      },
      "custom": {
        "displayMode": "color-text"
      }
    }
  },

  // options
  "options": {
    "showHeader": false,
  },

  // transformations
  "transformations": [
    {
      "id": "reduce"
    },
    {
      "id": "filterFieldsByName",
      "options": {
        "include": {
          "names": [
            "Field"
          ]
        }
      }
    }
  ]
};
// }}}
// {{{ panel: Avg duration
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
// }}}

// {{{ panel: Jobs recently created (TOP5)
local panelJobsTop5Created = {
  // type, title and description
  "type": "table",
  "title": "Jobs recently created (TOP5)",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "bottomk(5, time() - kube_job_created{namespace=~\"$namespace\"})",
      "legendFormat": "{{ job_name }} (ns: {{ namespace }})",
      "instant": true

    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "unit": "s"
    },
  },

  // options
  "options": {
    "showHeader": false
  },

  // transformations
  "transformations": [
    {
      "id": "reduce"
    }
  ]
};
/*
{
  "options": {
    "showHeader": true,
    "sortBy": [
      {
        "desc": false,
        "displayName": "Last (not null)"
      }
    ]
  },
  ,
  "transformations": [
    {
      "id": "reduce",
      "options": {
        "reducers": [
          "lastNotNull"
        ]
      }
    }
  ],
},
*/
// }}}
// {{{ panel: Jobs recently started (TOP5)
local panelJobsTop5Started = {
  // type, title and description
  "type": "table",
  "title": "Jobs recently started (TOP5)",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "bottomk(5, time() - kube_job_status_start_time{namespace=~\"$namespace\"})",
      "legendFormat": "{{ job_name }} (ns: {{ namespace }})",
      "instant": true

    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "unit": "s"
    },
  },

  // options
  "options": {
    "showHeader": false
  },

  // transformations
  "transformations": [
    {
      "id": "reduce"
    }
  ]
};
// }}}
// {{{ panel: Jobs recently completed (TOP5)
local panelJobsTop5Completed = {
  // type, title and description
  "type": "table",
  "title": "Jobs recently completed (TOP5)",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "bottomk(5, time() - kube_job_status_completion_time{namespace=~\"$namespace\"})",
      "legendFormat": "{{ job_name }} (ns: {{ namespace }})",
      "instant": true

    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "unit": "s"
    },
  },

  // options
  "options": {
    "showHeader": false
  },

  // transformations
  "transformations": [
    {
      "id": "reduce"
    }
  ]
};
// }}}
// {{{ panel: Long running jobs (TOP5)
local panelJobsTop5Running = {
  // type, title and description
  "type": "table",
  "title": "Long running jobs (TOP5)",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "topk(5, kube_job_status_completion_time{namespace=~\"$namespace\"} - kube_job_status_start_time{namespace=~\"$namespace\"})",
      "legendFormat": "{{ job_name }} (ns: {{ namespace }})",
      "instant": true

    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "unit": "s"
    },
  },

  // options
  "options": {
    "showHeader": false
  },

  // transformations
  "transformations": [
    {
      "id": "reduce"
    }
  ]
};
// }}}
// }}}
// {{{ row: PVs
// {{{ panel: Volumes
local panelPVsVolumes = {
  // type, title and description
  "type": "stat",
  "title": "Volumes",
  "description": "PV resource is `not namespaced`",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(kube_persistentvolume_info)",
      "instant": true,
    }
  ]
};
// }}}
// {{{ panel: Claims
local panelPVsClaims = {
  // type, title and description
  "type": "stat",
  "title": "Claims",
  "description": "Claim resource is `namespaced`",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(kube_persistentvolumeclaim_info{namespace=~\"$namespace\"})",
      "instant": true
    }
  ]
};
// }}}
// {{{ panel: Bound
local panelPVsBound = {
  // type, title and description
  "type": "stat",
  "title": "Bound",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(kube_persistentvolume_status_phase{namespace=~\"$namespace\", phase=\"Bound\"})",
      "instant": true
    }
  ]
};
// }}}
// {{{ panel: Unbound
local panelPVsUnbound = {
  // type, title and description
  "type": "stat",
  "title": "Unbound",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(kube_persistentvolume_status_phase{namespace=~\"$namespace\", phase!=\"Bound\"})",
      "instant": true
    }
  ]
};
// }}}
// {{{ panel: Top 5 PV
local panelPVsTop5PV = {
  // type, title and description
  "type": "table",
  "title": "Top 5 PV",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "topk(5, kube_persistentvolumeclaim_resource_requests_storage_bytes)",
      "legendFormat": "{{ persistentvolumeclaim }} (ns: {{ namespace }})",
      "instant": true
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "custom": {
        "displayMode": "color-text",
      },
      "decimals": 0,
      "unit": "bytes"
    }
  },

  // options
  "options": {
    "showHeader": false,
    "sortBy": [
      {
        "desc": true,
        "displayName": "Max"
      }
    ]
  },

  // transformations
  "transformations": [
    {
      "id": "reduce",
      "options": {
        "mode": "seriesToRows"
      }
    }
  ]
};

// }}}
// }}}
// }}}

dashboard
.addTemplate(varPrometheusDS)
.addTemplate(varNamespace)

// {{{ row: Cluster
.addPanel(
  grafana.row.new(title='Cluster', collapse=false),
  gridPos={x: 0, y: 0, w: 24, h: 1},
)

.addPanels(
  [
    panelClusterVersion     { gridPos: {x: 0,  y: 1, w: 3, h: 3} },
    panelNumberOfNodes      { gridPos: {x: 3,  y: 1, w: 3, h: 3} },
    panelOldestNodeAge      { gridPos: {x: 6,  y: 1, w: 3, h: 3} },
    panelNewestNodeAge      { gridPos: {x: 9,  y: 1, w: 3, h: 3} },
    panelNodesUnschedulable { gridPos: {x: 12, y: 1, w: 3, h: 3} },
    panelNodesBadCondition  { gridPos: {x: 15, y: 1, w: 9, h: 3} },

    panelClusterPodsAllocation  { gridPos: {x: 0,  y: 4, w: 8, h: 5} },
    panelClusterCpuRequested    { gridPos: {x: 8,  y: 4, w: 8, h: 5} },
    panelClusterMemoryRequested { gridPos: {x: 16, y: 4, w: 8, h: 5} },

    panelClusterPods   { gridPos: {x: 0,  y: 9, w: 8, h: 8} },
    panelClusterCpu    { gridPos: {x: 8,  y: 9, w: 8, h: 8} },
    panelClusterMemory { gridPos: {x: 16, y: 9, w: 8, h: 8} },
  ]
)
// }}}
// {{{ row: CPU and Memory
.addPanel(
  grafana.row.new(title='CPU and Memory', collapse=false),
  gridPos={x: 0, y: 17, w: 24, h: 1},
)
.addPanels(
  [
    panelCPUPercentBusy    { gridPos: {x: 0,  y: 18, w: 12, h: 8} },
    panelMemoryPercentUsed { gridPos: {x: 12, y: 18, w: 12, h: 8} },
  ]
)
// }}}
// {{{ row: Pods
.addPanel(
  grafana.row.new(title='Pods', collapse=true)
  .addPanels(
    [
      panelPodsOldest               { gridPos: {x: 0,  y: 27, w: 3, h: 4} },
      panelPodsNewest               { gridPos: {x: 0,  y: 31, w: 3, h: 4} },
      panelPodsPodsRunning          { gridPos: {x: 3,  y: 27, w: 3, h: 4} },
      panelPodsNewIn30Mins          { gridPos: {x: 3,  y: 31, w: 3, h: 4} },
      panelPodsPodsPending          { gridPos: {x: 6,  y: 27, w: 3, h: 4} },
      panelPodsPodsFailed           { gridPos: {x: 6,  y: 31, w: 3, h: 4} },

      panelPodsPods                 { gridPos: {x: 9,  y: 27, w: 15, h: 8} },

      panelPodsContainerRestarts    { gridPos: {x: 0,  y: 35, w: 3, h: 4} },
      panelPodsContainersWaiting    { gridPos: {x: 0,  y: 39, w: 3, h: 4} },
      panelPodsCPURequested         { gridPos: {x: 3,  y: 35, w: 3, h: 4} },
      panelPodsMemoryRequested      { gridPos: {x: 3,  y: 39, w: 3, h: 4} },

      panelPodsContainersError      { gridPos: {x: 6,  y: 35, w: 8, h: 8} },
      panelPodsContainersTerminated { gridPos: {x: 18,  y: 35, w: 10, h: 8} },
    ]
  ),
  gridPos={x: 0, y: 26, w: 24, h: 1},
)
// }}}
// {{{ row: Daemonsets
.addPanel(
  grafana.row.new(title='Daemonsets', collapse=true)
  .addPanels(
    [
      panelDaemonsetsDaemonsets  { gridPos: {x: 0,  y: 28, w: 3, h: 4} },
      panelDaemonsetsPods        { gridPos: {x: 0,  y: 32, w: 3, h: 4} },

      panelDaemonsetsUnavailable { gridPos: {x: 3,  y: 28, w: 21, h: 8} },
    ]
  ),
  gridPos={x: 0, y: 27, w: 24, h: 1},
)
// }}}
// {{{ row: Deployments
.addPanel(
  grafana.row.new(title='Deployments', collapse=true)
  .addPanels(
    [
      panelDeploymentsDeployments   { gridPos: {x: 0,  y: 29, w: 4, h: 4} },
      panelDeploymentsReplicas      { gridPos: {x: 0,  y: 29, w: 2, h: 4} },
      panelDeploymentsReplicasReady { gridPos: {x: 2,  y: 29, w: 2, h: 4} },

      panelDeploymentsReplicasTS    { gridPos: {x: 4,  y: 29, w: 11, h: 8} },
      panelDeploymentsMissing       { gridPos: {x: 15, y: 29, w: 9,  h: 8} },
    ]
  ),
  gridPos={x: 0, y: 28, w: 24, h: 1},
)
// }}}
// {{{ row: Statefulsets
.addPanel(
  grafana.row.new(title='Statefulsets', collapse=true)
  .addPanels(
    [
      panelStatefulsetsStatefulsets    { gridPos: {x: 0,  y: 30, w: 4, h: 4} },
      panelStatefulsetsReplicas        { gridPos: {x: 0,  y: 30, w: 2, h: 4} },
      panelStatefulsetsReplicasReady   { gridPos: {x: 2,  y: 30, w: 2, h: 4} },

      panelStatefulsetsReplicasReadyTS { gridPos: {x: 4,  y: 30, w: 11, h: 8} },
      panelStatefulsetsMissing         { gridPos: {x: 15, y: 30, w: 9,  h: 8} },
    ]
  ),
  gridPos={x: 0, y: 29, w: 24, h: 1},
)
// }}}
// {{{ row: Jobs
.addPanel(
  grafana.row.new(title='Jobs', collapse=true)
  .addPanels(
    [
      panelJobsCronJobs      { gridPos: {x: 0, y :31, w: 2,  h: 5} },
      panelJobsJobs          { gridPos: {x: 0, y :36, w: 2,  h: 5} },

      panelJobsJobsActive    { gridPos: {x: 2, y :31, w: 4,  h: 4} },
      panelJobsJobsSucceeded { gridPos: {x: 2, y :35, w: 4,  h: 3} },
      panelJobsJobsFailed    { gridPos: {x: 2, y :38, w: 4,  h: 3} },

      panelJobsLastSchedule  { gridPos: {x: 6, y :31, w: 7,  h: 5} },
      panelJobsNextSchedule  { gridPos: {x: 6, y :36, w: 7,  h: 5} },

      panelJobsFailedJobs    { gridPos: {x: 13, y :31, w: 8, h: 10} },
      panelJobsAvgDuration   { gridPos: {x: 21, y :31, w: 3, h: 10} },

      panelJobsTop5Created   { gridPos: {x: 0,  y :41, w: 6, h: 7} },
      panelJobsTop5Started   { gridPos: {x: 6,  y :41, w: 6, h: 7} },
      panelJobsTop5Completed { gridPos: {x: 12, y :41, w: 6, h: 7} },
      panelJobsTop5Running   { gridPos: {x: 18, y :41, w: 6, h: 7} },
    ]
  ),
  gridPos={x: 0, y: 30, w: 24, h: 1},
)
// }}}
// {{{ row: PVs
.addPanel(
  grafana.row.new(title='PVs', collapse=true)
  .addPanels(
    [
      panelPVsVolumes { gridPos: {x: 0,  y: 32, w: 3,  h: 4} },
      panelPVsClaims  { gridPos: {x: 0,  y: 36, w: 3,  h: 4} },

      panelPVsBound   { gridPos: {x: 3,  y: 32, w: 3,  h: 4} },
      panelPVsUnbound { gridPos: {x: 3,  y: 36, w: 3,  h: 4} },

      panelPVsTop5PV  { gridPos: {x: 6,  y: 32, w: 18, h: 8} },
    ]
  ),
  gridPos={x: 0, y: 31, w: 24, h: 1},
)
// }}}
