local grafana = import 'grafonnet/grafana.libsonnet';

local dashboard = grafana.dashboard.new(
  'K8S / Pod system stats',
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

local varPod = std.mergePatch(
  grafana.template.text(
    'pod', // name
  ),
  {
    "current": {
      "value": "_name_of_the_pod_"
    }
  }
);
// }}}

// {{{ panels
// {{{ panelStatAge
local panelStatAge = {
  // type, title and description
  "type": "stat",
  "title": "Age",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "time() - kube_pod_created{pod=~\"${pod}.*\"}",
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
    "colorMode": "none"
  }
};
// }}}
// {{{ panelStatRunning
local panelStatRunning = {
  // type, title and description
  "type": "stat",
  "title": "Running",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "kube_pod_container_status_terminated{pod=~\"${pod}.*\"}",
      "instant": true
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "mappings": [
        {
          "options": {
            "0": {
              "color": "super-light-green",
              "index": 0,
              "text": "True"
            },
            "1": {
              "color": "super-light-red",
              "index": 1,
              "text": "False"
            }
          },
          "type": "value"
        }
      ]
    }
  },

  // options
  "options": {
    "textMode": "value"
  }
};
// }}}
// {{{ panelStatInitContainers
local panelStatInitContainers = {
  // type, title and description
  "type": "stat",
  "title": "Init containers",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "count(kube_pod_init_container_info{pod=~\"${pod}.*\"})",
      "instant": true
    }
  ],

  // options
  "options": {
    "colorMode": "none"
  }
};
// }}}
// {{{ panelStatContainers
local panelStatContainers = {
  // type, title and description
  "type": "stat",
  "title": "Containers",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "count(kube_pod_container_info{pod=~\"${pod}.*\"})",
      "instant": true
    }
  ],

  // options
  "options": {
    "colorMode": "none"
  }
};

// }}}
// {{{ panelProcesses
local panelProcesses = {
  // type, title and description
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
      "expr": "sum(container_processes{pod=~\"${pod}.*\", container!=\"\", container!=\"POD\"})",
      "legendFormat": "processes"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "fixed",
        "fixedColor": "light-green"
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
// {{{ panelThreads
local panelThreads = {
  // type, title and description
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
      "expr": "sum(container_threads{pod=~\"${pod}.*\", container!=\"\", container!=\"POD\"})",
      "legendFormat": "threads"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "fixed",
        "fixedColor": "light-purple"
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
// {{{ panelSockets
local panelSockets = {
  // type, title and description
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
      "expr": "sum(container_sockets{pod=~\"${pod}.*\", container!=\"\", container!=\"POD\"})",
      "legendFormat": "sockets"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "fixed",
        "fixedColor": "light-yellow"
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
// {{{ panelFileDescriptors
local panelFileDescriptors = {
  // type, title and description
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
      "expr": "sum(container_file_descriptors{pod=~\"${pod}.*\", container!=\"\", container!=\"POD\"})",
      "legendFormat": "file_descriptors",
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "fixed",
        "fixedColor": "super-light-red"
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
// {{{ panelCPUUsage
local panelCPUUsage = {
  // type, title and description
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
      "expr": "irate(container_cpu_usage_seconds_total{pod=~\"${pod}.*\", container!=\"\", container!=\"POD\"}[$__rate_interval])",
      "legendFormat": "{{ container }}"
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
// {{{ panelCPUThrottled
local panelCPUThrottled = {
  // type, title and description
  "type": "timeseries",
  "title": "CPU throttled percentage",
  "description": "https://www.youtube.com/watch?v=UE7QX98-kO0",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "100 * (\n  increase(container_cpu_cfs_throttled_periods_total{pod=~\"${pod}.*\", container!=\"\", container!=\"POD\"}[$__rate_interval]) /\n  increase(container_cpu_cfs_periods_total{pod=~\"${pod}.*\", container!=\"\", container!=\"POD\"}[$__rate_interval])\n)",
      "legendFormat": "{{ container }}"
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
// {{{ panelMemoryUsage
local panelMemoryUsage = {
  // type, title and description
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
      "expr": "container_memory_working_set_bytes{pod=~\"${pod}.*\", container!=\"\", container!=\"POD\"}",
      "legendFormat": "{{ container }} (working set)",
      "hide": false
    },
    {
      "expr": "container_memory_usage_bytes{pod=~\"${pod}.*\", container!=\"\", container!=\"POD\"}",
      "legendFormat": "{{ container }} (usage)",
      "hide": true
    },
    {
      "expr": "container_memory_rss{pod=~\"${pod}.*\", container!=\"\", container!=\"POD\"}",
      "legendFormat": "{{ container }} (rss)",
      "hide": true
    },
    {
      "expr": "container_memory_mapped_file{pod=~\"${pod}.*\", container!=\"\", container!=\"POD\"}",
      "legendFormat": "{{ container }} (mapped files)",
      "hide": true
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic",
      },
      "unit": "bytes"
    }
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panelMemoryFailures
local panelMemoryFailures = {
  // type, title and description
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
      "expr": "rate(container_memory_failures_total{pod=~\"${pod}.*\", container!=\"\", container!=\"POD\", failure_type=\"pgfault\", scope=\"container\"}[$__rate_interval])",
      "legendFormat": "{{ container }} - {{ failure_type }}"
    },
    {
      "expr": "rate(container_memory_failures_total{pod=~\"${pod}.*\", container!=\"\", container!=\"POD\", failure_type=\"pgmajfault\", scope=\"container\"}[$__rate_interval])",
      "legendFormat": "{{ container }} - {{ failure_type }}"
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
// {{{ panelNetworkUsage
local panelNetworkUsage = {
  // type, title and description
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
      "expr": "irate(container_network_transmit_bytes_total{pod=~\"${pod}.*\"}[$__rate_interval])",
      "legendFormat": "tx"
    },
    {
      "expr": "irate(container_network_receive_bytes_total{pod=~\"${pod}.*\"}[$__rate_interval]) * -1",
      "legendFormat": "rx"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "#61e22a",
        "mode": "fixed"
      },
      "custom": {
        "fillOpacity": 10,
      },
      "unit": "binBps"
    },
    "overrides": [
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
// {{{ panelNetworkErrors
local panelNetworkErrors = {
  // type, title and description
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
      "expr": "sum(rate(container_network_transmit_packets_dropped_total{pod=~\"${pod}.*\"}[$__rate_interval]))",
      "legendFormat": "tx packets dropped"
    },
    {
      "expr": "sum(rate(container_network_transmit_errors_total{pod=~\"${pod}.*\"}[$__rate_interval]))",
      "legendFormat": "tx errors"
    },
    {
      "expr": "sum(rate(container_network_receive_packets_dropped_total{pod=~\"${pod}.*\"}[$__rate_interval]))",
      "legendFormat": "rx packets dropped"
    },
    {
      "expr": "sum(rate(container_network_receive_errors_total{pod=\"${pod}\"}[$__rate_interval]))",
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

dashboard
.addTemplate(varPrometheusDS)
.addTemplate(varPod)

.addPanels(
  [
    panelStatAge            { gridPos: {x: 0, y: 0, w: 2, h: 4} },
    panelStatRunning        { gridPos: {x: 0, y: 4, w: 2, h: 4} },
    panelStatInitContainers { gridPos: {x: 2, y: 0, w: 2, h: 4} },
    panelStatContainers     { gridPos: {x: 2, y: 4, w: 2, h: 4} },

    panelProcesses       { gridPos: {x: 4,  y: 0, w: 5, h: 8} },
    panelThreads         { gridPos: {x: 9,  y: 0, w: 5, h: 8} },
    panelSockets         { gridPos: {x: 14, y: 0, w: 5, h: 8} },
    panelFileDescriptors { gridPos: {x: 19, y: 0, w: 5, h: 8} },

    panelCPUUsage     { gridPos: {x: 0,  y: 8, w: 12, h: 8} },
    panelCPUThrottled { gridPos: {x: 12, y: 8, w: 12, h: 8} },

    panelMemoryUsage    { gridPos: {x: 0,  y: 16, w: 12, h: 8} },
    panelMemoryFailures { gridPos: {x: 12, y: 16, w: 12, h: 8} },

    panelNetworkUsage  { gridPos: {x: 0,  y: 24, w: 12, h: 8} },
    panelNetworkErrors { gridPos: {x: 12, y: 24, w: 12, h: 8} },
  ]
)
