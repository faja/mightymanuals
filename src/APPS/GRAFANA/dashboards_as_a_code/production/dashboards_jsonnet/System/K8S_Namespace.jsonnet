local grafana = import 'grafonnet/grafana.libsonnet';

local dashboard = grafana.dashboard.new(
  'K8S / Namespace',
  timezone='utc',
  time_from='now-3h',
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
    current='default',
  ),
  {
    "definition": "label_values(kube_namespace_created, namespace)",
  }
);
// }}}

// {{{ panels
// {{{ top row
// {{{ panel: Running pods
local panelRunningPods = {
  // type, title and description
  "type": "stat",
  "title": "Running pods",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(kube_pod_status_phase{namespace=~\"$namespace\", phase=\"Running\"})"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "fixed"
      }
    }
  },
};
// }}}
// {{{ panel: Processes
local panelProcesses = {
  // title and type
  "type": "timeseries",
  "title": "Processes",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(container_processes{namespace=\"$namespace\", container!=\"\", container!=\"POD\"})",
      "legendFormat": "processes"
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
      "min": 0
    }
  },

  // options
  "options": {
    "legend": {
      "displayMode": "hidden"
    }
  }
};
// }}}
// {{{ panel: Threads
local panelThreads = {
  // title and type
  "type": "timeseries",
  "title": "Threads",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(container_threads{namespace=\"$namespace\", container!=\"\", container!=\"POD\"})",
      "legendFormat": "threads"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "light-purple",
        "mode": "fixed"
      },
      "custom": {
        "fillOpacity": 10,
      },
      "min": 0
    }
  },

  // options
  "options": {
    "legend": {
      "displayMode": "hidden"
    }
  }
};
// }}}
// {{{ panel: Sockets
local panelSockets = {
  // title and type
  "type": "timeseries",
  "title": "Sockets",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(container_sockets{namespace=\"$namespace\", container!=\"\", container!=\"POD\"})",
      "legendFormat": "sockets"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "light-yellow",
        "mode": "fixed"
      },
      "custom": {
        "fillOpacity": 10,
      },
      "min": 0
    }
  },

  // options
  "options": {
    "legend": {
      "displayMode": "hidden"
    }
  }
};
// }}}
// {{{ panel: File descriptors
local panelFileDescriptors = {
  // title and type
  "type": "timeseries",
  "title": "File descriptors",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(container_file_descriptors{namespace=\"$namespace\", container!=\"\", container!=\"POD\"})",
      "legendFormat": "file_descriptors"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "super-light-red",
        "mode": "fixed"
      },
      "custom": {
        "fillOpacity": 10,
      },
      "min": 0
    }
  },

  // options
  "options": {
    "legend": {
      "displayMode": "hidden"
    }
  }
};
// }}}
// }}}
// {{{ row: Totals
// {{{ panel: CPU usage
local panelCPUUsage = {
  // title and type
  "type": "timeseries",
  "title": "CPU usage",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(irate(container_cpu_usage_seconds_total{namespace=\"$namespace\"}[$__rate_interval]))",
      "legendFormat": "total"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "super-light-green",
        "mode": "fixed"
      },
      "custom": {
        "fillOpacity": 12,
      }
    }
  },

  // options
  "options": {
    "legend": {
      "displayMode": "hidden"
    }
  }
};
// }}}
// {{{ panel: CPU throttled
local panelCPUThrottled = {
  // title and type
  "type": "timeseries",
  "title": "CPU throttled",
  "description": "https://www.youtube.com/watch?v=UE7QX98-kO0",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "100 * ( sum(increase(container_cpu_cfs_throttled_periods_total{namespace=\"${namespace}\"}[1m])) / sum(increase(container_cpu_cfs_periods_total{namespace=\"${namespace}\"}[1m])) )",
      "legendFormat": "throttled%"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      }
    }
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panel: Memory usage
local panelMemoryUsage = {
  // title and type
  "type": "timeseries",
  "title": "Memory usage",
  "description": "Memory usage is quite complex topic.\nBy default this panel shows `container_memory_working_set_bytes` metric (as it is usually slightly bigger than RSS (rss + mapped_file). \n\nUse 'edit' or 'explore' to see other memory metrics:\n- rss\n- mapped files\n- usage\n\n\nsee: https://lwn.net/Articles/432224/ for details",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(container_memory_working_set_bytes{namespace=\"${namespace}\"})",
      "legendFormat": "total (working set)"
    },
    {
      "expr": "sum(container_memory_rss{namespace=\"${namespace}\"})",
      "legendFormat": "total (rss)",
      "hide": true
    },
    {
      "expr": "sum(container_memory_usage_bytes{namespace=\"${namespace}\"})",
      "legendFormat": "total (usage)",
      "hide": true
    },
    {
      "expr": "sum(container_memory_mapped_file{namespace=\"${namespace}\"})",
      "legendFormat": "total (mapped files)",
      "hide": true
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "light-green",
        "mode": "fixed",
      },
      "custom": {
        "fillOpacity": 12,
      },
      "unit": "bytes"
    }
  },

  // options
  "options": {
    "legend": {
      "displayMode": "hidden"
    }
  }
};
// }}}
// {{{ panel: Memory failures
local panelMemoryFailures = {
  // title and type
  "type": "timeseries",
  "title": "Memory failures",
  "description": "- pgfaults are OK (no disk IO)\n- pgmajfaults are NOT OK (disk IO)",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(rate(container_memory_failures_total{namespace=\"$namespace\", failure_type=\"pgfault\"}[$__rate_interval]))",
      "legendFormat": "pgfault"
    },
    {
      "expr": "sum(rate(container_memory_failures_total{namespace=\"$namespace\", failure_type=\"pgmajfault\"}[$__rate_interval]))",
      "legendFormat": "pgmajfault"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      }
    }
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panel: Network usage
local panelNetworkUsage = {
  // title and type
  "type": "timeseries",
  "title": "Network usage",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(irate(container_network_transmit_bytes_total{namespace=\"${namespace}\"}[$__rate_interval]))",
      "legendFormat": "tx"
    },
    {
      "expr": "sum(irate(container_network_receive_bytes_total{namespace=\"${namespace}\"}[$__rate_interval]) * -1)",
      "legendFormat": "rx"
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
      "unit": "binBps"
    },
    "overrides": [
      {
        "matcher": {
          "id": "byName",
          "options": "tx"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "#61e22a",
              "mode": "fixed"
            }
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "rx"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "#eba4ed",
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
// {{{ panel: Network errors
local panelNetworkErrors = {
  // title and type
  "type": "timeseries",
  "title": "Network errors",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(rate(container_network_transmit_packets_dropped_total{namespace=\"${namespace}\"}[$__rate_interval]))",
      "legendFormat": "tx packets dropped"
    },
    {
      "expr": "sum(rate(container_network_transmit_errors_total{namespace=\"${namespace}\"}[$__rate_interval]))",
      "legendFormat": "tx errors"
    },
    {
      "expr": "sum(rate(container_network_receive_packets_dropped_total{namespace=\"${namespace}\"}[$__rate_interval]))",
      "legendFormat": "rx packets dropped"
    },
    {
      "expr": "sum(rate(container_network_receive_errors_total{namespace=\"${namespace}\"}[$__rate_interval]))",
      "legendFormat": "rx errors"
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
      "unit": "binBps"
    }
  },

  // options
  "options": {
  }
};
// }}}
// }}}
// {{{ row: Per container (TOP5)
// {{{ panel: CPU usage
local panelPerContainerCPUUsage = {
  // title and type
  "type": "timeseries",
  "title": "CPU usage",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "topk(5, sum by (pod, container) (\n  irate(container_cpu_usage_seconds_total{namespace=\"$namespace\", container!=\"\", container!=\"POD\"}[$__rate_interval])\n))",
      "legendFormat": "{{ pod }}/{{ container }}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 12,
      }
    }
  },

  // options
  "options": {
    "legend": {
      "calcs": [
        "lastNotNull",
        "last"
      ],
      "displayMode": "table",
      "placement": "right"
    },
  }
};
// }}}
// {{{ panel: Memory usage
local panelPerContainerMemoryUsage = {
  // title and type
  "type": "timeseries",
  "title": "Memory usage",
  "description": "This panel shows `container_memory_working_set_bytes` metric.",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "topk(5, sum by (pod, container) (\n  container_memory_working_set_bytes{namespace=\"$namespace\", container!=\"\", container!=\"POD\"}\n))",
      "legendFormat": "{{ pod }}/{{ container }}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 12,
      },
      "unit": "bytes"
    }
  },

  // options
  "options": {
    "legend": {
      "calcs": [
        "lastNotNull",
        "last"
      ],
      "displayMode": "table",
      "placement": "right"
    }
  }
};
// }}}
// {{{ panel: Network usage
local panelPerContainerNetworkUsage = {
  // title and type
  "type": "timeseries",
  "title": "Network usage",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "topk(5, sum by (pod, container) (\n  irate(container_network_transmit_bytes_total{namespace=\"$namespace\"}[$__rate_interval])\n))",
      "legendFormat": "{{ pod }}/{{ container }} - tx"
    },
    {
      "expr": "bottomk(5, sum by (pod, container) (\n  irate(container_network_receive_bytes_total{namespace=\"$namespace\"}[$__rate_interval]) * -1\n))",
      "legendFormat": "{{ pod }}/{{ container }} - rx"
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
      "unit": "binBps"
    }
  },

  // options
  "options": {
    "legend": {
      "calcs": [
        "lastNotNull",
        "last"
      ],
      "displayMode": "table",
      "placement": "right"
    }
  }
};
// }}}
// }}}
// }}}

dashboard
.addTemplate(varPrometheusDS)
.addTemplate(varNamespace)

// {{{ top row
.addPanels(
  [
    panelRunningPods     { gridPos: {x: 0,  y: 0, w: 4, h: 8} },
    panelProcesses       { gridPos: {x: 4,  y: 0, w: 5, h: 8} },
    panelThreads         { gridPos: {x: 9,  y: 0, w: 5, h: 8} },
    panelSockets         { gridPos: {x: 14, y: 0, w: 5, h: 8} },
    panelFileDescriptors { gridPos: {x: 19, y: 0, w: 5, h: 8} },
  ]
)
// }}}
// {{{ row: Totals
.addPanel(
  grafana.row.new(title='Totals', collapse=true)
  .addPanels(
    [
      panelCPUUsage       { gridPos: {x: 0,  y: 9, w: 12,  h: 8} },
      panelCPUThrottled   { gridPos: {x: 12, y: 9, w: 12,  h: 8} },

      panelMemoryUsage    { gridPos: {x: 0,  y: 17, w: 12,  h: 8} },
      panelMemoryFailures { gridPos: {x: 12, y: 17, w: 12,  h: 8} },

      panelNetworkUsage   { gridPos: {x: 0,  y: 25, w: 12,  h: 8} },
      panelNetworkErrors  { gridPos: {x: 12, y: 25, w: 12,  h: 8} },
    ]
  ),
  gridPos={x: 0, y: 8, w: 24, h: 1},
)
// }}}
// {{{ row: Per container (TOP5)
.addPanel(
  grafana.row.new(title='Per container (TOP5)', collapse=true)
  .addPanels(
    [
      panelPerContainerCPUUsage     { gridPos: {x: 0,  y: 10, w: 24,  h: 8} },
      panelPerContainerMemoryUsage  { gridPos: {x: 0,  y: 18, w: 24,  h: 8} },
      panelPerContainerNetworkUsage { gridPos: {x: 0,  y: 26, w: 24,  h: 8} },
    ]
  ),
  gridPos={x: 0, y: 9, w: 24, h: 1},
)
// }}}
