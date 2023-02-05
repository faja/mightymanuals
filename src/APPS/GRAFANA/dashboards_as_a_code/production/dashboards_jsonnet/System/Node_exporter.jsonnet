local grafana = import 'grafonnet/grafana.libsonnet';

local dashboard = grafana.dashboard.new(
  'Node exporter',
  timezone='utc',
  time_from='now-3h',
  editable=false,
);

// {{{ dashboard variables/templates
local varPrometheusDS = grafana.template.datasource(
  'PROMETHEUS_DS', // name
  'prometheus',    // query
  'prometheus',    // current
  hide=true,       // ''      - disables hiding at all, everything is displayed
                   // 'label' - hide the name of the variable, and the drop down is displayed
                   // any other value - hides everything
  //regex='/prometheus/',
);

local varJob = grafana.template.custom(
  'job',           // name
  'node_exporter', // query
  'node_exporter', // current
  hide=true,
);

local varNode = std.mergePatch(
  grafana.template.new(
    'node',                                                    // name
    {"type": "prometheus", "uid": "${PROMETHEUS_DS}"},         // datasource
    "label_values(node_uname_info{job=\"${job}\"}, nodename)", // query
    sort=1,                                                    // sort alphabetical (asc) 
  ),
  {
    "definition": "label_values(node_uname_info{job=\"${job}\"}, nodename)"
  }
);

local varInstance = std.mergePatch(
  grafana.template.new(
    'instance',                                                                      // name
    {"type": "prometheus", "uid": "${PROMETHEUS_DS}"},                               // datasource
    "label_values(node_uname_info{job=\"${job}\", nodename=\"${node}\"}, instance)", // query
    hide=true,
  ),
  {
    "definition": "label_values(node_uname_info{job=\"${job}\", nodename=\"${node}\"}, instance)"
  }
);
// }}}

// {{{ panels definition
// {{{ panelOverviewCPUCores
local panelOverviewCPUCores = {
  // type, title and description
  "type": "stat",
  "title": "CPU Cores",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "count(\n  count by (cpu) (node_cpu_seconds_total{job=\"${job}\", instance=\"${instance}\"})\n)",
      "instant": true
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "unit": "short"
    }
  },

  // options
  "options": {
    "colorMode": "none",
  }
};
// }}}
// {{{ panelOverviewCPUBusy
local panelOverviewCPUBusy = {
  // type, title and description
  "type": "gauge",
  "title": "CPU Busy (last 15m)",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [

    {
      "expr": "(\n  (\n    count(count by (cpu) (node_cpu_seconds_total{job=\"${job}\", instance=\"${instance}\"})) -                              # number of cores -\n    avg_over_time(sum(rate(node_cpu_seconds_total{mode=\"idle\", job=\"${job}\", instance=\"${instance}\"}[$__rate_interval]))[15m:15m])    # sum of all cpu time in idle mode, this is average over last 30 minutes\n                                                                                                                    # (this gives us how much busy the cpu where)\n   ) /                                                                                                              # divided by\n   count(count by (cpu) (node_cpu_seconds_total{job=\"${job}\", instance=\"${instance}\"}))                                 # number of cores\n) * 100                                                                                                             # and to have a nice % multiple by 100\n\n \n   ",
      "instant": true
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "thresholds"
      },
      "thresholds": {
        "mode": "absolute",
        "steps": [
          {
            "color": "green",
            "value": null
          },
          {
            "color": "#EAB839",
            "value": 80
          },
          {
            "color": "red",
            "value": 90
          }
        ]
      },
      "decimals": 0,
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
// {{{ panelOverviewMemoryTotal
local panelOverviewMemoryTotal = {
  // type, title and description
  "type": "stat",
  "title": "Total RAM",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "node_memory_MemTotal_bytes{job=\"${job}\", instance=\"${instance}\"}",
      "instant": true
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "decimals": 2,
      "unit": "decbytes"
    }
  },

  // options
  "options": {
    "colorMode": "none",
  }
};
// }}}
// {{{ panelOverviewMemoryUsed
local panelOverviewMemoryUsed = {
  // type, title and description
  "type": "gauge",
  "title": "Used RAM",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "# there is no such thing as USED memory metric\n# hence we calculate % available, and do \"100 - VALUE\" to get % USED\n100 - (\n  100 * (\n    node_memory_MemAvailable_bytes{job=\"${job}\", instance=\"${instance}\"} /\n    node_memory_MemTotal_bytes{job=\"${job}\", instance=\"${instance}\"}\n  )\n)",
      "instant": true
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "thresholds"
      },
      "thresholds": {
        "mode": "absolute",
        "steps": [
          {
            "color": "green",
            "value": null
          },
          {
            "color": "#EAB839",
            "value": 80
          },
          {
            "color": "red",
            "value": 90
          }
        ]
      },
      "decimals": 0,
      "displayName": "",
      "max": 100,
      "min": 0,
      "unit": "percent"
    },
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panelOverviewSultan
local panelOverviewSultan = grafana.text.new(
  transparent=false,
  mode='html',
  content='<img \nwidth=\"100%\"\nheight=\"100%\"\nsrc=\"https://public.amsdard.io/kapitan_bomba/001.jpg\">\n</img>',
);
// }}}
// {{{ panelOverviewRootFSTotal
local panelOverviewRootFSTotal = {
  // type, title and description
  "type": "stat",
  "title": "Total RootFS",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "node_filesystem_size_bytes{job=\"${job}\", instance=\"${instance}\", mountpoint=\"/\"}",
      "instant": true
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "decimals": 2,
      "unit": "decbytes"
    }
  },

  // options
  "options": {
    "colorMode": "none",
  }
};
// }}}
// {{{ panelOverviewRootFSUsed
local panelOverviewRootFSUsed = {
  // type, title and description
  "type": "gauge",
  "title": "Used RootFS",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "# node_exporter does not expose node_filesystem_USED_bytes\n# hence we calculate % available, and do \"100 - VALUE\" to get % USED\n100 - (\n  100 * (\n    node_filesystem_avail_bytes{job=\"${job}\", instance=\"${instance}\", mountpoint=\"/\", fstype!=\"rootfs\"} /\n    node_filesystem_size_bytes{job=\"${job}\", instance=\"${instance}\", mountpoint=\"/\", fstype!=\"rootfs\"}\n  )\n)",
      "instant": true
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "thresholds"
      },
      "thresholds": {
        "mode": "absolute",
        "steps": [
          {
            "color": "green",
            "value": null
          },
          {
            "color": "#EAB839",
            "value": 80
          },
          {
            "color": "red",
            "value": 90
          }
        ]
      },
      "decimals": 0,
      "displayName": "",
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
// {{{ panelOverviewUptime
local panelOverviewUptime = {
  // type, title and description
  "type": "stat",
  "title": "Uptime",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "time() - node_boot_time_seconds{job=\"${job}\", instance=\"${instance}\"}",
      "instant": true
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "decimals": 1,
      "unit": "s"
    }
  },

  // options
  "options": {
    "colorMode": "none",
  }
};
// }}}
// {{{ panelOverviewLoad1
local panelOverviewLoad1 = {
  // type, title and description
  "type": "gauge",
  "title": "System Load 1m (last 15m)",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "100 * (\n  avg(avg_over_time(node_load1{job=\"${job}\", instance=\"${instance}\"}[15m:15m])) /\n  count(count(node_cpu_seconds_total{job=\"${job}\", instance=\"${instance}\"}) by (cpu)) # number of cpus\n)",
      "instant": true
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "thresholds"
      },
      "thresholds": {
        "mode": "absolute",
        "steps": [
          {
            "color": "green",
            "value": null
          },
          {
            "color": "#EAB839",
            "value": 80
          },
          {
            "color": "red",
            "value": 90
          }
        ]
      },
      "decimals": 0,
      "displayName": "",
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
// {{{ panelOverviewKernel
local panelOverviewKernel = {
  // type, title and description
  "type": "stat",
  "title": "Kernel",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "node_uname_info{job=\"${job}\", instance=\"${instance}\"}",
      "instant": true,
      "legendFormat": "{{ release }}"
    }
  ],

  // filedConfig
  "fieldConfig": {
  },

  // options
  "options": {
    "textMode": "name",
    "colorMode": "none",
  }
};
// }}}
// {{{ panelOverviewLoad15
local panelOverviewLoad15 = {
  // type, title and description
  "type": "gauge",
  "title": "System Load 15m (last 15m)",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "100 * (\n  avg(avg_over_time(node_load15{job=\"${job}\", instance=\"${instance}\"}[15m:15m])) /\n  count(count(node_cpu_seconds_total{job=\"${job}\", instance=\"${instance}\"}) by (cpu)) # number of cpus\n)",
      "instant": true
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "thresholds"
      },
      "thresholds": {
        "mode": "absolute",
        "steps": [
          {
            "color": "green",
            "value": null
          },
          {
            "color": "#EAB839",
            "value": 80
          },
          {
            "color": "red",
            "value": 90
          }
        ]
      },
      "decimals": 0,
      "displayName": "",
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

// {{{ panelBasicCPU
local panelBasicCPU = {
  // type, title and description
  "type": "timeseries",
  "title": "CPU by mode",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(irate(node_cpu_seconds_total{mode=\"system\", job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])) * 100",
      "legendFormat": "Busy System"
    },
    {
      "expr": "sum(irate(node_cpu_seconds_total{mode=\"user\", job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])) * 100",
      "legendFormat": "Busy User"
    },
    {
      "expr": "sum(irate(node_cpu_seconds_total{mode=\"iowait\", job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])) * 100",
      "legendFormat": "Busy Iowait"
    },
    {
      "expr": "sum(irate(node_cpu_seconds_total{mode!='idle',mode!='user',mode!='system',mode!='iowait', job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])) * 100",
      "legendFormat": "Busy Other"
    },
    {
      "expr": "sum(irate(node_cpu_seconds_total{mode=\"idle\", job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])) * 100",
      "legendFormat": "Idle"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "custom": {
        "fillOpacity": 40,
        "stacking": {
          "mode": "normal"
        },
      },
      "unit": "short"
    },
    "overrides": [
      {
        "matcher": {
          "id": "byName",
          "options": "Idle"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "#73BF69",
              "mode": "fixed"
            }
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "Busy System"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "#F2495C",
              "mode": "fixed"
            }
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "Busy User"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "#FADE2A",
              "mode": "fixed"
            }
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "Busy Iowait"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "#B877D9",
              "mode": "fixed"
            }
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "Busy Other"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "#5794F2",
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
// {{{ panelBasicMemory
local panelBasicMemory = {
  // type, title and description
  "type": "timeseries",
  "title": "Memory",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "node_memory_MemTotal_bytes{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "RAM Total"
    },
    {
      "expr": "node_memory_MemTotal_bytes{job=\"${job}\", instance=\"${instance}\"} -\n(\n  node_memory_MemFree_bytes{job=\"${job}\", instance=\"${instance}\"} + \n  node_memory_Cached_bytes{job=\"${job}\", instance=\"${instance}\"} +\n  node_memory_Buffers_bytes{job=\"${job}\", instance=\"${instance}\"}\n)",
      "legendFormat": "RAM Used"
    },
    {
      "expr": "node_memory_Cached_bytes{job=\"${job}\", instance=\"${instance}\"} + node_memory_Buffers_bytes{job=\"${job}\", instance=\"${instance}\"}    ",
      "legendFormat": "RAM Cache + Buffer"
    },
    {
      "expr": "node_memory_MemFree_bytes{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "RAM Free"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "custom": {
        "fillOpacity": 40,
        "stacking": {
          "mode": "normal"
        }
      },
      "min": 0,
      "unit": "decbytes"
    },
    "overrides": [
      {
        "matcher": {
          "id": "byName",
          "options": "RAM Total"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "rgb(255, 255, 255)",
              "mode": "fixed"
            }
          },
          {
            "id": "custom.fillOpacity",
            "value": 0
          },
          {
            "id": "custom.lineWidth",
            "value": 2
          },
          {
            "id": "custom.stacking",
            "value": {
              "group": false,
              "mode": "normal"
            }
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "RAM Used"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "#F2495C",
              "mode": "fixed"
            }
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "RAM Cache + Buffer"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "#FADE2A",
              "mode": "fixed"
            }
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "RAM Free"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "#73BF69",
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

// {{{ panelBasicDiskSpace
local panelBasicDiskSpace = {
  // type, title and description
  "type": "timeseries",
  "title": "Disk Space Used by mountpoint",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "100 - (\n  100 * (\n    node_filesystem_avail_bytes{device!=\"tmpfs\", device!=\"rootfs\", job=\"${job}\", instance=\"${instance}\"} /\n    node_filesystem_size_bytes{device!=\"tmpfs\", device!=\"rootfs\", job=\"${job}\", instance=\"${instance}\"}\n  )\n)",
      "legendFormat": "{{ mountpoint }}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 40,
        "thresholdsStyle": {
          "mode": "line"
        }
      },
      "thresholds": {
        "mode": "absolute",
        "steps": [
          {
            "color": "green",
            "value": null
          },
          {
            "color": "red",
            "value": 88
          }
        ]
      },
      "decimals": 2,
      "max": 100,
      "min": 0,
      "unit": "percent"
    },
    "overrides": [
      {
        "matcher": {
          "id": "byName",
          "options": "/"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "rgb(35, 176, 159)",
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
// {{{ panelBasicNetwork
local panelBasicNetwork = {
  // type, title and description
  "type": "timeseries",
  "title": "Network Traffic",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "irate(node_network_receive_bytes_total{device!=\"lo\", job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])",
      "legendFormat": "recv {{ device }}"
    },
    {
      "expr": "irate(node_network_transmit_bytes_total{device!=\"lo\", job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])\n\n  * (-1) \n  # unfortunately new 'time series' panel does not support negative Y \n  # until it supports it we have to do ugly (* -1) by hand\n  # not nice :( grafana not nice :(",
      "legendFormat": "send {{ device }}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 40
      },
      "unit": "Bps"
    }
  },

  // options
  "options": {
  }
};
// }}}

// {{{ panelDetailedSystemLoad
local panelDetailedSystemLoad = {
  // type, title and description
  "type": "timeseries",
  "title": "System Load",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "node_load1{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "Load 1m"
    },
    {
      "expr": "node_load5{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "Load 5m"
    },
    {
      "expr": "node_load15{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "Load 15m"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 20
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
// {{{ panelDetailedSystemSpaceAndInodes
local panelDetailedSystemSpaceAndInodes = {
  // type, title and description
  "type": "timeseries",
  "title": "Space and Inodes Used by mountpoint",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "100 - (\n  100 * (\n    node_filesystem_avail_bytes{device!=\"tmpfs\", device!=\"rootfs\", job=\"${job}\", instance=\"${instance}\"} /\n    node_filesystem_size_bytes{device!=\"tmpfs\", device!=\"rootfs\", job=\"${job}\", instance=\"${instance}\"}\n  )\n)",
      "legendFormat": "{{ mountpoint }} - space"
    },
    {
      "expr": "100 - (\n  100 * (\n    node_filesystem_files_free{device!=\"tmpfs\", device!=\"rootfs\", job=\"${job}\", instance=\"${instance}\"} /\n    node_filesystem_files{device!=\"tmpfs\", device!=\"rootfs\", job=\"${job}\", instance=\"${instance}\"}\n  )\n)",
      "legendFormat": "{{ mountpoint }} - inodes"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 20,
        "thresholdsStyle": {
          "mode": "line"
        }
      },
      "thresholds": {
        "mode": "absolute",
        "steps": [
          {
            "color": "green",
            "value": null
          },
          {
            "color": "red",
            "value": 88
          }
        ]
      },
      "decimals": 2,
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
// {{{ panelDetailedSystemFileDescriptors
local panelDetailedSystemFileDescriptors = {
  // type, title and description
  "type": "timeseries",
  "title": "File Descriptors",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "node_filefd_maximum{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "Max open files"
    },
    {
      "expr": "node_filefd_allocated{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "Open files"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "fixed",
        "fixedColor": "rgb(23, 153, 136)"
      },
      "custom": {
        "fillOpacity": 20
      },
      "min": 0,
      "unit": "short"
    },
    "overrides": [
      {
        "matcher": {
          "id": "byName",
          "options": "Open files"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "rgb(159, 42, 230)",
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
// {{{ panelDetailedSystemSockets
local panelDetailedSystemSockets = {
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
      "expr": "node_sockstat_sockets_used{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "All sockets"
    },
    {
      "expr": "node_sockstat_TCP_inuse{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "TCP sockets in use"
    },
    {
      "expr": "node_sockstat_UDP_inuse{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "UDP sockets in use"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "fixed",
        "fixedColor": "rgb(255, 255, 255)"
      },
      "custom": {
        "fillOpacity": 20
      },
      "min": 0,
      "unit": "short"
    },
    "overrides": [
      {
        "matcher": {
          "id": "byName",
          "options": "TCP sockets in use"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "#FFA6B0",
              "mode": "fixed"
            }
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "UDP sockets in use"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "#DEB6F2",
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
// {{{ panelDetailedSystemContexSwitches
local panelDetailedSystemContexSwitches = {
  // type, title and description
  "type": "timeseries",
  "title": "Context Switches / Interrupts",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "irate(node_context_switches_total{job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])",
      "legendFormat": "Context switches"
    },
    {
      "expr": "irate(node_intr_total{job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])",
      "legendFormat": "Interrupts"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 20
      },
      "unit": "short"
    }
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panelDetailedSystemProcesses
local panelDetailedSystemProcesses = {
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
      "expr": "node_processes_pids{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "processes"
    },
    {
      "expr": "node_processes_threads{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "threads"
    },
    {
      "expr": "node_processes_max_processes{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "processes limit"
    },
    {
      "expr": "node_processes_max_threads{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "threads limit"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 20
      },
      "unit": "short"
    },
    "overrides": [
      {
        "matcher": {
          "id": "byName",
          "options": "processes limit"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "#C4162A",
              "mode": "fixed"
            }
          },
          {
            "id": "custom.fillOpacity",
            "value": 0
          },
          {
            "id": "custom.lineWidth",
            "value": 2
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "threads limit"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "#E02F44",
              "mode": "fixed"
            }
          },
          {
            "id": "custom.fillOpacity",
            "value": 0
          },
          {
            "id": "custom.lineWidth",
            "value": 2
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
// {{{ panelDetailedSystemForks
local panelDetailedSystemForks = {
  // type, title and description
  "type": "timeseries",
  "title": "Processes  Forks / Processes State",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "node_procs_running{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "processes running"
    },
    {
      "expr": "node_procs_blocked{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "processes blocked"
    },
    {
      "expr": "irate(node_forks_total{job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])",
      "legendFormat": "forks / second"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "fixed",
        "fixedColor": "rgb(39, 235, 108)"
      },
      "custom": {
        "fillOpacity": 20
      },
      "min": 0,
      "unit": "short"
    },
    "overrides": [
      {
        "matcher": {
          "id": "byName",
          "options": "forks / second"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "#FF9830",
              "mode": "fixed"
            }
          },
          {
            "id": "custom.axisLabel",
            "value": "forks/sec"
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "processes blocked"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "rgb(237, 28, 124)",
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

// {{{ panelDetailedMemoryUsage
local panelDetailedMemoryUsage = {
  // type, title and description
  "type": "timeseries",
  "title": "Memory",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "node_memory_MemTotal_bytes{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "RAM Total"
    },
    {
      "expr": "node_memory_MemFree_bytes{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "RAM Free"
    },
    {
      "expr": "node_memory_Cached_bytes{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "RAM Cache"
    },
    {
      "expr": "node_memory_Buffers_bytes{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "RAM Buffer"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "fixed",
        "fixedColor": "rgb(0, 255, 148)"
      },
      "custom": {
        "fillOpacity": 40
      },
      "min": 0,
      "unit": "decbytes"
    },
    "overrides": [
      {
        "matcher": {
          "id": "byName",
          "options": "RAM Total"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "#FFA6B0",
              "mode": "fixed"
            }
          },
          {
            "id": "custom.fillOpacity",
            "value": 0
          },
          {
            "id": "custom.lineWidth",
            "value": 3
          },
          {
            "id": "custom.stacking",
            "value": {
              "group": false,
              "mode": "normal"
            }
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "RAM Cache"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "rgb(87, 189, 71)",
              "mode": "fixed"
            }
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "RAM Buffer"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "rgb(42, 250, 225)",
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
// {{{ panelDetailedMemoryPagesInOut
local panelDetailedMemoryPagesInOut = {
  // type, title and description
  "type": "timeseries",
  "title": "Memory Pages In/Out",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "irate(node_vmstat_pgpgin{job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])",
      "legendFormat": "In"
    },
    {
      "expr": "irate(node_vmstat_pgpgout{job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])",
      "legendFormat": "Out"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "fixed",
        "fixedColor": "#B877D9"
      },
      "custom": {
        "fillOpacity": 20
      },
      "unit": "ops"
    },
    "overrides": [
      {
        "matcher": {
          "id": "byName",
          "options": "Out"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "#5794F2",
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
// {{{ panelDetailedMemoryPageFaults
local panelDetailedMemoryPageFaults = {
  // type, title and description
  "type": "timeseries",
  "title": "Memory Page Faults",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "irate(node_vmstat_pgfault{job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])",
      "legendFormat": "Minor"
    },
    {
      "expr": "irate(node_vmstat_pgmajfault{job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])",
      "legendFormat": "Major"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "fixed",
        "fixedColor": "#FFEE52"
      },
      "custom": {
        "fillOpacity": 20
      },
      "unit": "ops"
    },
    "overrides": [
      {
        "matcher": {
          "id": "byName",
          "options": "Major"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "#FA6400",
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
// {{{ panelDetailedMemoryDirty
local panelDetailedMemoryDirty = {
  // type, title and description
  "type": "timeseries",
  "title": "Memory Writeback and Dirty",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "node_memory_Dirty_bytes{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "Dirty"
    },
    {
      "expr": "node_memory_Writeback_bytes{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "Writeback"
    },
    {
      "expr": "node_memory_WritebackTmp_bytes{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "WritebackTmp"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "fixed",
        "fixedColor": "rgb(12, 184, 0)"
      },
      "custom": {
        "fillOpacity": 20
      },
      "unit": "decbytes"
    },
    "overrides": [
      {
        "matcher": {
          "id": "byName",
          "options": "Writeback"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "rgb(37, 84, 16)",
              "mode": "fixed"
            }
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "WritebackTmp"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "#C8F2C2",
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
// {{{ panelDetailedMemoryKernel
local panelDetailedMemoryKernel = {
  // type, title and description
  "type": "timeseries",
  "title": "Memory Kernel Stack",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "node_memory_KernelStack_bytes{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "KernelStack"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "fixed",
        "fixedColor": "#B877D9"
      },
      "custom": {
        "fillOpacity": 20
      },
      "unit": "decbytes"
    }
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panelDetailedMemoryActiveInactive
local panelDetailedMemoryActiveInactive = {
  // type, title and description
  "type": "timeseries",
  "title": "Memory Active/Inactive",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "node_memory_Active_bytes{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "Active: all"
    },
    {
      "expr": "node_memory_Active_anon_bytes{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "Active: anon"
    },
    {
      "expr": "node_memory_Active_file_bytes{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "Active: file"
    },
    {
      "expr": "node_memory_Inactive_bytes{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "Inactive: all"
    },
    {
      "expr": "node_memory_Inactive_anon_bytes{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "Inactive: anon"
    },
    {
      "expr": "node_memory_Inactive_file_bytes{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "Inactive: file"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 20
      },
      "unit": "decbytes"
    }
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panelDetailedMemoryCommited
local panelDetailedMemoryCommited = {
  // type, title and description
  "type": "timeseries",
  "title": "Memory Commited AS",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "node_memory_Committed_AS_bytes{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "Commited"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "fixed",
        "fixedColor": "#FF7383"
      },
      "custom": {
        "fillOpacity": 20
      },
      "unit": "decbytes"
    }
  },

  // options
  "options": {
  }
};
// }}}

// {{{ panelDetailedDiskIOps
local panelDetailedDiskIOps = {
  // type, title and description
  "type": "timeseries",
  "title": "Disk IOps",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "irate(node_disk_reads_completed_total{job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])",
      "legendFormat": "{{ device }} - reads"
    },
    {
      "exemplar": true,
      "expr": "irate(node_disk_writes_completed_total{job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])\n  * (-1) \n  # unfortunately new 'time series' panel does not support negative Y \n  # until it supports it we have to do ugly (* -1) by hand\n  # not nice :( grafana not nice :(",
      "legendFormat": "{{ device }} - writes"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 20
      },
      "unit": "iops"
    },
    "overrides": [
      {
        "matcher": {
          "id": "byRegexp",
          "options": "/reads/"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "super-light-blue",
              "mode": "fixed"
            }
          }
        ]
      },
      {
        "matcher": {
          "id": "byRegexp",
          "options": "/write/"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "red",
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
// {{{ panelDetailedDiskIOTime
local panelDetailedDiskIOTime = {
  // type, title and description
  "type": "timeseries",
  "title": "Disk IO Time",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "irate(node_disk_read_time_seconds_total{job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])",
      "legendFormat": "{{ device }} - read time"
    },
    {
      "exemplar": true,
      "expr": "irate(node_disk_write_time_seconds_total{job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])\n\n  * (-1) \n  # unfortunately new 'time series' panel does not support negative Y \n  # until it supports it we have to do ugly (* -1) by hand\n  # not nice :( grafana not nice :(",
      "legendFormat": "{{ device }} - write time"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 20
      },
      "unit": "s"
    },
    "overrides": [
      {
        "matcher": {
          "id": "byRegexp",
          "options": "/read/"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "super-light-blue",
              "mode": "fixed"
            }
          }
        ]
      },
      {
        "matcher": {
          "id": "byRegexp",
          "options": "/write/"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "red",
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
// {{{ panelDetailedDiskIOBytes
local panelDetailedDiskIOBytes = {
  // type, title and description
  "type": "timeseries",
  "title": "Disk IO Bytes",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "irate(node_disk_read_bytes_total{job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])",
      "legendFormat": "{{ device }} - read bytes"
    },
    {
      "expr": "irate(node_disk_written_bytes_total{job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])\n\n  * (-1) \n  # unfortunately new 'time series' panel does not support negative Y \n  # until it supports it we have to do ugly (* -1) by hand\n  # not nice :( grafana not nice :(",
      "legendFormat": "{{ device }} - written bytes"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 20
      },
      "unit": "Bps"
    },
    "overrides": [
      {
        "matcher": {
          "id": "byRegexp",
          "options": "/read/"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "super-light-blue",
              "mode": "fixed"
            }
          }
        ]
      },
      {
        "matcher": {
          "id": "byRegexp",
          "options": "/written/"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "red",
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
// {{{ panelDetailedDiskIOMerged
local panelDetailedDiskIOMerged = {
  // type, title and description
  "type": "timeseries",
  "title": "Disk IOps Merged",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "irate(node_disk_reads_merged_total{job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])",
      "legendFormat": "{{ device }} - reads"
    },
    {
      "exemplar": true,
      "expr": "irate(node_disk_writes_merged_total{job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])\n\n  * (-1) \n  # unfortunately new 'time series' panel does not support negative Y \n  # until it supports it we have to do ugly (* -1) by hand\n  # not nice :( grafana not nice :(",
      "legendFormat": "{{ device }} - writes"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 20
      },
      "unit": "iops"
    },
    "overrides": [
      {
        "matcher": {
          "id": "byRegexp",
          "options": "/read/"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "super-light-blue",
              "mode": "fixed"
            }
          }
        ]
      },
      {
        "matcher": {
          "id": "byRegexp",
          "options": "/writes/"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "red",
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
// {{{ panelDetailedDiskIONow
local panelDetailedDiskIONow = {
  // type, title and description
  "type": "timeseries",
  "title": "Disk IO now",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "irate(node_disk_io_now{job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])",
      "legendFormat": "{{ device }} - io now"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 20
      },
      "unit": "s"
    },
    "overrides": [
      {
        "matcher": {
          "id": "byRegexp",
          "options": "/io now/"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "light-yellow",
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

// {{{ panelDetailedNetworkTrafficBytes
local panelDetailedNetworkTrafficBytes = {
  // type, title and description
  "type": "timeseries",
  "title": "Bytes/s",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "irate(node_network_receive_bytes_total{device!=\"lo\", job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])",
      "legendFormat": "{{ device }} - receive"
    },
    {
      "exemplar": true,
      "expr": "irate(node_network_transmit_bytes_total{device!=\"lo\", job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])\n\n  * (-1) \n  # unfortunately new 'time series' panel does not support negative Y \n  # until it supports it we have to do ugly (* -1) by hand\n  # not nice :( grafana not nice :(",
      "legendFormat": "{{ device }} - transmit"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 20
      },
      "unit": "Bps"
    }
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panelDetailedNetworkTrafficPackets
local panelDetailedNetworkTrafficPackets = {
  // type, title and description
  "type": "timeseries",
  "title": "Packets/s",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "irate(node_network_receive_packets_total{device!=\"lo\", job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])",
      "legendFormat": "{{ device }} - receive"
    },
    {
      "expr": "irate(node_network_transmit_packets_total{device!=\"lo\", job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])\n\n  * (-1) \n  # unfortunately new 'time series' panel does not support negative Y \n  # until it supports it we have to do ugly (* -1) by hand\n  # not nice :( grafana not nice :(",
      "legendFormat": "{{ device }} - transmit"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 20
      },
      "decimals": 2,
      "unit": "pps"
    }
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panelDetailedNetworkTrafficDropped
local panelDetailedNetworkTrafficDropped = {
  // type, title and description
  "type": "timeseries",
  "title": "Dropped/s",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "irate(node_network_receive_drop_total{device!=\"lo\", job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])",
      "legendFormat": "{{ device }} - receive drop"
    },
    {
      "exemplar": true,
      "expr": "irate(node_network_transmit_drop_total{device!=\"lo\", job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])\n\n  * (-1) \n  # unfortunately new 'time series' panel does not support negative Y \n  # until it supports it we have to do ugly (* -1) by hand\n  # not nice :( grafana not nice :(",
      "legendFormat": "{{ device }} - transmit drop"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 20
      },
      "decimals": 2,
      "unit": "pps"
    }
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panelDetailedNetworkTrafficErrors
local panelDetailedNetworkTrafficErrors = {
  // type, title and description
  "type": "timeseries",
  "title": "Errors/s",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "irate(node_network_receive_errs_total{device!=\"lo\", job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])",
      "legendFormat": "{{ device }} - receive errors"
    },
    {
      "exemplar": true,
      "expr": "irate(node_network_transmit_errs_total{device!=\"lo\", job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])\n\n  * (-1) \n  # unfortunately new 'time series' panel does not support negative Y \n  # until it supports it we have to do ugly (* -1) by hand\n  # not nice :( grafana not nice :(",
      "legendFormat": "{{ device }} - transmit errors"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 20
      },
      "decimals": 2,
      "unit": "pps"
    }
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panelDetailedNetworkTrafficARP
local panelDetailedNetworkTrafficARP = {
  // type, title and description
  "type": "timeseries",
  "title": "ARP Entries",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "node_arp_entries{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "{{ device }}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 20
      },
      "unit": "short"
    }
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panelDetailedNetworkTrafficConntrack
local panelDetailedNetworkTrafficConntrack = {
  // type, title and description
  "type": "timeseries",
  "title": "NF Conntrack",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "node_nf_conntrack_entries{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "NF conntrack entries"
    },
    {
      "expr": "node_nf_conntrack_entries_limit{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "NF conntrack limit"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 20
      },
      "unit": "short"
    }
  },

  // options
  "options": {
  }
};
// }}}

// {{{ panelDetailedNetworkIP
local panelDetailedNetworkIP = {
  // type, title and description
  "type": "timeseries",
  "title": "IP Packets In/Out (per second)",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "irate(node_netstat_IpExt_InOctets{job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])",
      "legendFormat": "In Octets"
    },
    {
      "expr": "irate(node_netstat_IpExt_OutOctets{job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])\n\n  * (-1) \n  # unfortunately new 'time series' panel does not support negative Y \n  # until it supports it we have to do ugly (* -1) by hand\n  # not nice :( grafana not nice :(",
      "legendFormat": "Out Octets"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 20
      },
      "unit": "short"
    }
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panelDetailedNetworkIP6
local panelDetailedNetworkIP6 = {
  // type, title and description
  "type": "timeseries",
  "title": "IPv6 Packets In/Out (per second)",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "irate(node_netstat_Ip6_InOctets{job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])",
      "legendFormat": "In Octets"
    },
    {
      "expr": "irate(node_netstat_Ip6_OutOctets{job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])\n\n  * (-1) \n  # unfortunately new 'time series' panel does not support negative Y \n  # until it supports it we have to do ugly (* -1) by hand\n  # not nice :( grafana not nice :(",
      "legendFormat": "Out Octets"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 20
      },
      "unit": "short"
    }
  },

  // options
  "options": {
  }
};
// }}}

// {{{ panelDetailedNetworkTCPInOut
local panelDetailedNetworkTCPInOut = {
  // type, title and description
  "type": "timeseries",
  "title": "TCP In/Out (per second)",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "irate(node_netstat_Tcp_InSegs{job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])",
      "legendFormat": "In Segments"
    },
    {
      "expr": "irate(node_netstat_Tcp_OutSegs{job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])\n\n  * (-1) \n  # unfortunately new 'time series' panel does not support negative Y \n  # until it supports it we have to do ugly (* -1) by hand\n  # not nice :( grafana not nice :(",
      "legendFormat": "Out Segments"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 20
      },
      "unit": "short"
    }
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panelDetailedNetworkTCPStates
local panelDetailedNetworkTCPStates = {
  // type, title and description
  "type": "timeseries",
  "title": "TCP states",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "node_tcp_connection_states{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "{{ state }}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 20
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
// {{{ panelDetailedNetworkTCPConnections
local panelDetailedNetworkTCPConnections = {
  // type, title and description
  "type": "timeseries",
  "title": "TCP Connections (per second)",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "node_netstat_Tcp_CurrEstab{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "Established"
    },
    {
      "expr": "irate(node_netstat_Tcp_ActiveOpens{job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])",
      "legendFormat": "Active Opens"
    },
    {
      "expr": "irate(node_netstat_Tcp_PassiveOpens{job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])",
      "legendFormat": "Passive Opens"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 20
      },
      "min": 0,
      "unit": "short"
    },
    "overrides": [
      {
        "matcher": {
          "id": "byName",
          "options": "Established"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "#B877D9",
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
// {{{ panelDetailedNetworkTCPSyncookies
local panelDetailedNetworkTCPSyncookies = {
  // type, title and description
  "type": "timeseries",
  "title": "TCP Syncookies (per second)",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "irate(node_netstat_TcpExt_SyncookiesRecv{job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])",
      "legendFormat": "Syncookies Received"
    },
    {
      "expr": "irate(node_netstat_TcpExt_SyncookiesSent{job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])",
      "legendFormat": "Syncookies Sent"
    },
    {
      "expr": "irate(node_netstat_TcpExt_SyncookiesFailed{job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])",
      "legendFormat": "Syncookies Failed"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 20
      },
      "unit": "short"
    }
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panelDetailedNetworkTCPListenErrors
local panelDetailedNetworkTCPListenErrors = {
  // type, title and description
  "type": "timeseries",
  "title": "TCP Listen Errors (per second)",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "irate(node_netstat_TcpExt_ListenDrops{job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])",
      "legendFormat": "ListenDrops"
    },
    {
      "expr": "irate(node_netstat_TcpExt_ListenOverflows{job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])",
      "legendFormat": "ListenOverflows"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "fixed",
        "fixedColor": "#FFA6B0"
      },
      "custom": {
        "fillOpacity": 20
      },
      "unit": "short"
    },
    "overrides": [
      {
        "matcher": {
          "id": "byName",
          "options": "ListenOverflows"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "#C4162A",
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
// {{{ panelDetailedNetworkTCPErrors
local panelDetailedNetworkTCPErrors = {
  // type, title and description
  "type": "timeseries",
  "title": "TCP Retransmits and Errors (per second)",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "irate(node_netstat_Tcp_InErrs{job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])",
      "legendFormat": "In Errors"
    },
    {
      "expr": "irate(node_netstat_Tcp_RetransSegs{job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])",
      "legendFormat": "Segments retransmits"
    },
    {
      "expr": "irate(node_netstat_TcpExt_TCPSynRetrans{job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])",
      "legendFormat": "TCP SYN retransmits"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "fixed",
        "fixedColor": "red"
      },
      "custom": {
        "fillOpacity": 20
      },
      "unit": "short"
    },
    "overrides": [
      {
        "matcher": {
          "id": "byName",
          "options": "Segments retransmits"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "#FFA6B0",
              "mode": "fixed"
            }
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "TCP SYN retransmits"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "rgb(198, 110, 252)",
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

// {{{ panelDetailedNetworkUDPInOut
local panelDetailedNetworkUDPInOut = {
  // type, title and description
  "type": "timeseries",
  "title": "UDP In/Out (per second)",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "irate(node_netstat_Udp_InDatagrams{job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])",
      "legendFormat": "In Datagrams"
    },
    {
      "expr": "irate(node_netstat_Udp_OutDatagrams{job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])\n\n  * (-1) \n  # unfortunately new 'time series' panel does not support negative Y \n  # until it supports it we have to do ugly (* -1) by hand\n  # not nice :( grafana not nice :(",
      "legendFormat": "Out Datagrams"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 20
      },
      "unit": "short"
    }
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panelDetailedNetworkUDPErrors
local panelDetailedNetworkUDPErrors = {
  // type, title and description
  "type": "timeseries",
  "title": "UDP Errors (per second)",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "irate(node_netstat_Udp_InErrors{job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])",
      "legendFormat": "In Errors"
    },
    {
      "expr": "irate(node_netstat_Udp_NoPorts{job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])",
      "legendFormat": "No Ports"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 20
      },
      "min": 0,
      "unit": "short"
    },
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panelDetailedNetworkICMPInOut
local panelDetailedNetworkICMPInOut = {
  // type, title and description
  "type": "timeseries",
  "title": "ICMP In/Out (per second)",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "irate(node_netstat_Icmp_InMsgs{job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])",
      "legendFormat": "In Msgs"
    },
    {
      "expr": "irate(node_netstat_Icmp_OutMsgs{job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])\n\n  * (-1) \n  # unfortunately new 'time series' panel does not support negative Y \n  # until it supports it we have to do ugly (* -1) by hand\n  # not nice :( grafana not nice :(",
      "legendFormat": "Out Msgs"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "fixed",
        "fixedColor": "rgb(119, 117, 199)"
      },
      "custom": {
        "fillOpacity": 20
      },
      "unit": "short"
    },
    "overrides": [
      {
        "matcher": {
          "id": "byName",
          "options": "Out Msgs"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "rgb(84, 219, 184)",
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
// {{{ panelDetailedNetworkICMPErrors
local panelDetailedNetworkICMPErrors = {
  // type, title and description
  "type": "timeseries",
  "title": "ICMP Errors (per second)",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "irate(node_netstat_Icmp_InErrors{job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])",
      "legendFormat": "In Errors"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "fixed",
        "fixedColor": "red"
      },
      "custom": {
        "fillOpacity": 20
      },
      "unit": "short"
    }
  },

  // options
  "options": {
  }
};
// }}}

// {{{ panelInternalScrapes
local panelInternalScrapes = {
  // type, title and description
  "type": "timeseries",
  "title": "Scrapes",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "scrape_samples_scraped{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "Samples scraped"
    },
    {
      "expr": "scrape_series_added{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "Series added"
    },
    {
      "expr": "scrape_duration_seconds{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "Scrape duration"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 20,
      },
      "decimals": 0,
      "unit": "short"
    },
    "overrides": [
      {
        "matcher": {
          "id": "byName",
          "options": "Samples scraped"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "#5794F2",
              "mode": "fixed"
            }
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "Scrape duration"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "#F2495C",
              "mode": "fixed"
            }
          },
          {
            "id": "unit",
            "value": "s"
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
// {{{ panelInternalHttpResponses
local panelInternalHttpResponses = {
  // type, title and description
  "type": "timeseries",
  "title": "Http responses (PER MINUTE)",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "rate(promhttp_metric_handler_requests_total{job=\"${job}\", instance=\"${instance}\"}[$__rate_interval]) * 60",
      "legendFormat": "{{ code }}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 20
      },
      "unit": "reqps"
    }
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panelInternalDuration
local panelInternalDuration = {
  // type, title and description
  "type": "timeseries",
  "title": "Collector duration",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "node_scrape_collector_duration_seconds{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "{{ collector }}"
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
      "unit": "s"
    }
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panelInternalCPU
local panelInternalCPU = {
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
      "expr": "rate(process_cpu_seconds_total{job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])",
      "legendFormat": "cpu"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "fixed",
        "fixedColor": "#CA95E5"
      },
      "custom": {
        "fillOpacity": 20
      },
      "decimals": 2,
      "unit": "s"
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
// {{{ panelInternalMemory
local panelInternalMemory = {
  // type, title and description
  "type": "timeseries",
  "title": "Memory usage",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "rate(go_memstats_alloc_bytes_total{job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])",
      "legendFormat": "allocations"
    },
    {
      "expr": "process_resident_memory_bytes{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "resident memory"
    },
    {
      "expr": "process_virtual_memory_bytes{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "virtual memory"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "custom": {
        "fillOpacity": 20
      },
      "unit": "decbytes"
    },
    "overrides": [
      {
        "matcher": {
          "id": "byName",
          "options": "allocations"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "#CA95E5",
              "mode": "fixed"
            }
          },
          {
            "id": "unit",
            "value": "Bps"
          },
          {
            "id": "custom.axisPlacement",
            "value": "right"
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "resident memory"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "#F2495C",
              "mode": "fixed"
            }
          },
          {
            "id": "custom.fillOpacity",
            "value": 40
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "virtual memory"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "#FFF899",
              "mode": "fixed"
            }
          },
          {
            "id": "custom.fillOpacity",
            "value": 30
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
// {{{ panelInternalHeap
local panelInternalHeap = {
  // type, title and description
  "type": "timeseries",
  "title": "Heap",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "go_memstats_heap_objects{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "objects"
    },
    {
      "expr": "go_memstats_heap_idle_bytes{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "idle"
    },
    {
      "expr": "go_memstats_heap_inuse_bytes{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "in use"
    },
    {
      "expr": "go_memstats_heap_sys_bytes{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "sys"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "custom": {
        "fillOpacity": 20,
        "stacking": {
          "mode": "normal"
        }
      },
      "min": 0,
      "unit": "decbytes"
    },
    "overrides": [
      {
        "matcher": {
          "id": "byName",
          "options": "objects"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "#CA95E5",
              "mode": "fixed"
            }
          },
          {
            "id": "custom.stacking",
            "value": {
              "group": false,
              "mode": "none"
            }
          },
          {
            "id": "unit",
            "value": "short"
          },
          {
            "id": "custom.axisPlacement",
            "value": "right"
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "in use"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "#F2495C",
              "mode": "fixed"
            }
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "idle"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "#73BF69",
              "mode": "fixed"
            }
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "sys"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "rgb(255, 255, 255)",
              "mode": "fixed"
            }
          },
          {
            "id": "custom.fillOpacity",
            "value": 0
          },
          {
            "id": "custom.lineWidth",
            "value": 2
          },
          {
            "id": "custom.stacking",
            "value": {
              "group": false,
              "mode": "normal"
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
// {{{ panelInternalOpenFiles
local panelInternalOpenFiles = {
  // type, title and description
  "type": "timeseries",
  "title": "Open Files",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "process_max_fds{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "max"
    },
    {
      "expr": "process_open_fds{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "open files"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "fixed",
        "fixedColor": "#FADE2A"
      },
      "custom": {
        "fillOpacity": 20
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
              "fixedColor": "#C4162A",
              "mode": "fixed"
            }
          },
          {
            "id": "custom.fillOpacity",
            "value": 0
          },
          {
            "id": "custom.lineWidth",
            "value": 2
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
// {{{ panelInternalGC
local panelInternalGC = {
  // type, title and description
  "type": "timeseries",
  "title": "Garbage Collection",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "rate(go_gc_duration_seconds_count{job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])*60",
      "legendFormat": "GC count / minute"
    },
    {
      "expr": "irate(go_gc_duration_seconds_sum{job=\"${job}\", instance=\"${instance}\"}[$__rate_interval])",
      "legendFormat": "GC time (avg)"
    },
    {
      "expr": "go_gc_duration_seconds{job=\"${job}\", instance=\"${instance}\", quantile=\"1\"}",
      "legendFormat": "GC time (q=1)"
    },
    {
      "expr": "go_gc_duration_seconds{job=\"${job}\", instance=\"${instance}\", quantile=\"0.75\"}",
      "legendFormat": "GC time (q=0.75)"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 20
      },
      "unit": "none"
    },
    "overrides": [
      {
        "matcher": {
          "id": "byRegexp",
          "options": "/GC time/"
        },
        "properties": [
          {
            "id": "custom.axisPlacement",
            "value": "right"
          },
          {
            "id": "unit",
            "value": "s"
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
// {{{ panelInternalThreads
local panelInternalThreads = {
  // type, title and description
  "type": "timeseries",
  "title": "Goroutines and Threads",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "go_goroutines{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "goroutines"
    },
    {
      "expr": "go_threads{job=\"${job}\", instance=\"${instance}\"}",
      "legendFormat": "threads"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 20
      },
      "unit": "short"
    }
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panelInternalAppVersion
local panelInternalAppVersion = {
  // type, title and description
  "type": "stat",
  "title": "App version",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "node_exporter_build_info{job=\"${job}\", instance=\"${instance}\"}",
      "instant": true,
      "legendFormat": "{{ version }}"
    }
  ],

  // filedConfig
  "fieldConfig": {
  },

  // options
  "options": {
    "textMode": "name",
    "colorMode": "none"
  }
};
// }}}
// {{{ panelInternalGOVersion
local panelInternalGOVersion = {
  // type, title and description
  "type": "stat",
  "title": "GO version",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "node_exporter_build_info{job=\"${job}\", instance=\"${instance}\"}",
      "instant": true,
      "legendFormat": "{{ goversion }}"
    }
  ],

  // filedConfig
  "fieldConfig": {
  },

  // options
  "options": {
    "textMode": "name",
    "colorMode": "none",
  }
};
// }}}
// {{{ panelInternalUptime
local panelInternalUptime = {
  // type, title and description
  "type": "stat",
  "title": "Uptime",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "time() - process_start_time_seconds{job=\"${job}\", instance=\"${instance}\"}",
      "instant": true
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "decimals": 1,
      "unit": "s"
    }
  },

  // options
  "options": {
    "colorMode": "none",
  }
};
// }}}
// }}}

dashboard
.addTemplate(varPrometheusDS)
.addTemplate(varJob)
.addTemplate(varNode)
.addTemplate(varInstance)

// {{{ panels (add)
.addPanels(
  [
    grafana.row.new(title='Overview: CPU / Mem / Disk', collapse=false) { gridPos: {x: 0, y: 0, w: 24, h: 1} },
    panelOverviewCPUCores    { gridPos: {x: 0,  y: 1, w: 4, h: 2} },
    panelOverviewCPUBusy     { gridPos: {x: 0,  y: 3, w: 4, h: 5} },
    panelOverviewMemoryTotal { gridPos: {x: 4,  y: 1, w: 4, h: 2} },
    panelOverviewMemoryUsed  { gridPos: {x: 4,  y: 3, w: 4, h: 5} },
    panelOverviewSultan      { gridPos: {x: 8,  y: 1, w: 4, h: 7} },
    panelOverviewRootFSTotal { gridPos: {x: 12, y: 1, w: 4, h: 2} },
    panelOverviewRootFSUsed  { gridPos: {x: 12, y: 3, w: 4, h: 5} },
    panelOverviewUptime      { gridPos: {x: 16, y: 1, w: 4, h: 2} },
    panelOverviewLoad1       { gridPos: {x: 16, y: 3, w: 4, h: 5} },
    panelOverviewKernel      { gridPos: {x: 20, y: 1, w: 4, h: 2} },
    panelOverviewLoad15      { gridPos: {x: 20, y: 3, w: 4, h: 5} },
  ]
)
// {{{ row: Basic: CPU/Mem
.addPanel(
  grafana.row.new(title='Basic: CPU / Mem', collapse=true)
  .addPanels(
    [
      panelBasicCPU    { gridPos: {x: 0,  y: 9, w: 12, h: 8} },
      panelBasicMemory { gridPos: {x: 12, y: 9, w: 12, h: 8} },
    ]
  ),
  gridPos={X: 0, y: 8, w: 24, h: 1},
)
// }}}
// {{{ row: Basic: Disk/Net
.addPanel(
  grafana.row.new(title='Basic: Disk / Net', collapse=true)
  .addPanels(
    [
      panelBasicDiskSpace { gridPos: {x: 0,  y: 10, w: 12, h: 8} },
      panelBasicNetwork   { gridPos: {x: 12, y: 10, w: 12, h: 8} },
    ]
  ),
  gridPos={X: 0, y: 9, w: 24, h: 1},
)
// }}}
// {{{ row: Detailed: System
.addPanel(
  grafana.row.new(title='Detailed: System', collapse=true)
  .addPanels(
    [
      panelDetailedSystemLoad           { gridPos: {x: 0,  y: 11, w: 12, h: 8} },
      panelDetailedSystemSpaceAndInodes { gridPos: {x: 12, y: 11, w: 12, h: 8} },

      panelDetailedSystemFileDescriptors { gridPos: {x: 0,  y: 19, w: 8, h: 8} },
      panelDetailedSystemSockets         { gridPos: {x: 8,  y: 19, w: 8, h: 8} },
      panelDetailedSystemContexSwitches  { gridPos: {x: 16, y: 19, w: 8, h: 8} },

      panelDetailedSystemProcesses { gridPos: {x: 0,  y: 27, w: 12, h: 8} },
      panelDetailedSystemForks     { gridPos: {x: 12, y: 27, w: 12, h: 8} },
    ]
  ),
  gridPos={X: 0, y: 10, w: 24, h: 1},
)
// }}}
// {{{ row: Detailed: Memory
.addPanel(
  grafana.row.new(title='Detailed: Memory', collapse=true)
  .addPanels(
    [
      panelDetailedMemoryUsage          { gridPos: {x: 0,  y: 12, w: 24, h: 8} },
      panelDetailedMemoryPagesInOut     { gridPos: {x: 0,  y: 20, w: 12, h: 8} },
      panelDetailedMemoryPageFaults     { gridPos: {x: 12, y: 20, w: 12, h: 8} },
      panelDetailedMemoryDirty          { gridPos: {x: 0,  y: 28, w: 12, h: 8} },
      panelDetailedMemoryKernel         { gridPos: {x: 12, y: 28, w: 12, h: 8} },
      panelDetailedMemoryActiveInactive { gridPos: {x: 0,  y: 36, w: 12, h: 8} },
      panelDetailedMemoryCommited       { gridPos: {x: 12, y: 36, w: 12, h: 8} },

    ]
  ),
  gridPos={X: 0, y: 11, w: 24, h: 1},
)
// }}}
// {{{ row: Detailed: Disk IO
.addPanel(
  grafana.row.new(title='Detailed: Disk IO', collapse=true)
  .addPanels(
    [
      panelDetailedDiskIOps     { gridPos: {x: 0,  y: 13, w: 8,  h: 8} },
      panelDetailedDiskIOTime   { gridPos: {x: 8,  y: 13, w: 8,  h: 8} },
      panelDetailedDiskIOBytes  { gridPos: {x: 16, y: 13, w: 8,  h: 8} },
      panelDetailedDiskIOMerged { gridPos: {x: 0,  y: 21, w: 12, h: 8} },
      panelDetailedDiskIONow    { gridPos: {x: 12, y: 21, w: 12, h: 8} },
    ]
  ),
  gridPos={X: 0, y: 12, w: 24, h: 1},
)
// }}}
// {{{ row: Detailed: Network Traffic
.addPanel(
  grafana.row.new(title='Detailed: Network Traffic', collapse=true)
  .addPanels(
    [
      panelDetailedNetworkTrafficBytes     { gridPos: {x: 0,  y: 14, w: 12, h: 8} },
      panelDetailedNetworkTrafficPackets   { gridPos: {x: 12, y: 14, w: 12, h: 8} },
      panelDetailedNetworkTrafficDropped   { gridPos: {x: 0,  y: 22, w: 12, h: 8} },
      panelDetailedNetworkTrafficErrors    { gridPos: {x: 12, y: 22, w: 12, h: 8} },
      panelDetailedNetworkTrafficARP       { gridPos: {x: 0,  y: 30, w: 12, h: 8} },
      panelDetailedNetworkTrafficConntrack { gridPos: {x: 12, y: 30, w: 12, h: 8} },
    ]
  ),
  gridPos={X: 0, y: 13, w: 24, h: 1},
)
// }}}
// {{{ row: Detailed: Network IP
.addPanel(
  grafana.row.new(title='Detailed: Network IP', collapse=true)
  .addPanels(
    [
      panelDetailedNetworkIP  { gridPos: {x: 0,  y: 15, w: 12, h: 8} },
      panelDetailedNetworkIP6 { gridPos: {x: 12, y: 15, w: 12, h: 8} },
    ]
  ),
  gridPos={X: 0, y: 14, w: 24, h: 1},
)
// }}}
// {{{ row: Detailed: Network TCP
.addPanel(
  grafana.row.new(title='Detailed: Network TCP', collapse=true)
  .addPanels(
    [
      panelDetailedNetworkTCPInOut        { gridPos: {x: 0,  y: 16, w: 12, h: 8} },
      panelDetailedNetworkTCPStates       { gridPos: {x: 12, y: 16, w: 12, h: 8} },
      panelDetailedNetworkTCPConnections  { gridPos: {x: 0,  y: 24, w: 12, h: 8} },
      panelDetailedNetworkTCPSyncookies   { gridPos: {x: 12, y: 24, w: 12, h: 8} },
      panelDetailedNetworkTCPListenErrors { gridPos: {x: 0,  y: 32, w: 12, h: 8} },
      panelDetailedNetworkTCPErrors       { gridPos: {x: 12, y: 32, w: 12, h: 8} },
    ]
  ),
  gridPos={X: 0, y: 15, w: 24, h: 1},
)
// }}}
// {{{ row: Detailed: Network UDP and ICMP
.addPanel(
  grafana.row.new(title='Detailed: Network UDP and ICMP', collapse=true)
  .addPanels(
    [
      panelDetailedNetworkUDPInOut   { gridPos: {x: 0,  y: 17, w: 12, h: 8} },
      panelDetailedNetworkUDPErrors  { gridPos: {x: 12, y: 17, w: 12, h: 8} },
      panelDetailedNetworkICMPInOut  { gridPos: {x: 0,  y: 25, w: 12, h: 8} },
      panelDetailedNetworkICMPErrors { gridPos: {x: 12, y: 25, w: 12, h: 8} },
    ]
  ),
  gridPos={X: 0, y: 16, w: 24, h: 1},
)
// }}}
// {{{ row: Internal: Process and Scrape Info
.addPanel(
  grafana.row.new(title='Internal: Process and Scrape Info', collapse=true)
  .addPanels(
    [
      panelInternalScrapes       { gridPos: {x: 0,  y: 18, w: 8,  h: 8} },
      panelInternalHttpResponses { gridPos: {x: 8,  y: 18, w: 8,  h: 8} },
      panelInternalDuration      { gridPos: {x: 16, y: 18, w: 8,  h: 8} },

      panelInternalCPU    { gridPos: {x: 0,  y: 26, w: 8,  h: 8} },
      panelInternalMemory { gridPos: {x: 8,  y: 26, w: 8,  h: 8} },
      panelInternalHeap   { gridPos: {x: 16, y: 26, w: 8,  h: 8} },

      panelInternalOpenFiles { gridPos: {x: 0,  y: 34, w: 6,  h: 8} },
      panelInternalGC        { gridPos: {x: 6,  y: 34, w: 6,  h: 8} },
      panelInternalThreads   { gridPos: {x: 12, y: 34, w: 6,  h: 8} },

      panelInternalAppVersion { gridPos: {x: 18, y: 34, w: 3,  h: 4} },
      panelInternalGOVersion  { gridPos: {x: 18, y: 38, w: 3,  h: 4} },
      panelInternalUptime     { gridPos: {x: 21, y: 34, w: 3,  h: 8} },
    ]
  ),
  gridPos={X: 0, y: 17, w: 24, h: 1},
)
// }}}
// }}}
