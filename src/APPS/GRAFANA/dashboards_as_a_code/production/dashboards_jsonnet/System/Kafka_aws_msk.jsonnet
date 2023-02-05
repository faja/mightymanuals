local grafana = import 'grafonnet/grafana.libsonnet';

local dashboard = grafana.dashboard.new(
  'Kafka (AWS MSK)',
  timezone='utc',
  time_from='now-12h',
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

local varJobNode = grafana.template.custom(
  'job_node',       // name
  'kafka-msk-node', // query
  'kafka-msk-node', // current
  hide=true,
);

local varJobJmx = grafana.template.custom(
  'job_jmx',       // name
  'kafka-msk-jmx', // query
  'kafka-msk-jmx', // current
  hide=true,
);

local varNodename = std.mergePatch(
  grafana.template.new(
    'nodename',                                       // name
    {"type": "prometheus", "uid": "${PROMETHEUS_DS}"}, // datasource
    "label_values(node_exporter_build_info{job=\"${job_node}\"}, nodename)", // query
  ),
  {
    "definition": "label_values(node_exporter_build_info{job=\"${job_node}\"}, nodename)",
  }
);

local varTopic = std.mergePatch(
  grafana.template.new(
    'topic',                                       // name
    {"type": "prometheus", "uid": "${PROMETHEUS_DS}"}, // datasource
    "label_values(kafka_log_Log_Value{job=\"${job_jmx}\"}, topic)", // query
  ),
  {
    "definition": "label_values(kafka_log_Log_Value{job=\"${job_jmx}\"}, topic)",
  }
);
// }}}

// {{{ panels
// {{{ panelClusterBrokers
local panelClusterBrokers = {
  // type, title and description
  "type": "stat",
  "title": "Brokers",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "max(kafka_server_KafkaServer_Value{job=\"${job_jmx}\", name=\"BrokerState\"})",
      "instant": true
    }
  ],

  "options": {
    "colorMode": "none",
  }
};
// }}}
// {{{ panelClusterTopics
local panelClusterTopics = {
  // type, title and description
  "type": "stat",
  "title": "Topics",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(kafka_controller_KafkaController_Value{job=\"${job_jmx}\", name=\"GlobalTopicCount\"})"
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

  // options
  "options": {
    "colorMode": "none",
  }
};
// }}}
// {{{ panelClusterPartitions
local panelClusterPartitions = {
  // type, title and description
  "type": "stat",
  "title": "Partitions",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(kafka_controller_KafkaController_Value{job=\"${job_jmx}\", name=\"GlobalPartitionCount\"})"
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

  // options
  "options": {
    "colorMode": "none",
  }
};
// }}}
// {{{ panelClusterConnections
local panelClusterConnections = {
  // type, title and description
  "type": "timeseries",
  "title": "Connections",
  "description": "Excluding replication connections",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum by (nodename) (kafka_server_socket_server_metrics_connection_count{job=\"${job_jmx}\", listener=\"CLIENT_SECURE\"})",
      "legendFormat": "{{ nodename }}"
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
// {{{ panelClusterBytes
local panelClusterBytes = {
  // type, title and description
  "type": "timeseries",
  "title": "Bytes / s",
  "description": "Including replication",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum by (nodename) (rate(kafka_server_socket_server_metrics_incoming_byte_total{job=\"${job_jmx}\"}[$__rate_interval]))",
      "legendFormat": "in {{ nodename }}"
    },
    {
      "expr": "sum by (nodename) (rate(kafka_server_socket_server_metrics_outgoing_byte_total{job=\"${job_jmx}\"}[$__rate_interval])) * -1",
      "legendFormat": "out {{ nodename }}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "unit": "bytes"
    }
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panelClusterRequests
local panelClusterRequests = {
  // type, title and description
  "type": "timeseries",
  "title": "Requests / s",
  "description": "Including replication",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum by (nodename) (rate(kafka_server_socket_server_metrics_request_total{job=\"${job_jmx}\"}[$__rate_interval]))",
      "legendFormat": "req {{ nodename }}"
    },
    {
      "expr": "sum by (nodename) (rate(kafka_server_socket_server_metrics_response_total{job=\"${job_jmx}\"}[$__rate_interval])) * -1",
      "legendFormat": "resp {{ nodename }}"
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
// {{{ panelClusterCPU
local panelClusterCPU = {
  // type, title and description
  "type": "timeseries",
  "title": "CPU busy (%)",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "100 * (  \n  sum by (nodename) (irate(node_cpu_seconds_total{mode!=\"idle\", job=\"${job_node}\"}[$__rate_interval]))\n    /\n  sum by (nodename) (irate(node_cpu_seconds_total{job=\"${job_node}\"}[$__rate_interval]))\n)",
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
        "fillOpacity": 40
      },
      "unit": "none"
    }
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panelClusterDiskSpace
local panelClusterDiskSpace = {
  // type, title and description
  "type": "timeseries",
  "title": "Disk space used (%)",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "# this super ugly query is simply (100 * (USED / TOTAL)) to get used percentage\n# but calculated per broker per mountpoint\n# also USED is calculated as TOTAL-AVAILABLE\n\n100 * (\n\n  (\n    (sum by (nodename, mountpoint) (node_filesystem_size_bytes{job=\"${job_node}\"}) -\n    (sum by (nodename, mountpoint) (node_filesystem_avail_bytes{job=\"${job_node}\"})))\n  ) /\n  (sum by (nodename, mountpoint) (node_filesystem_size_bytes{job=\"${job_node}\"}))\n)",
      "legendFormat": "{{ nodename }}  - {{ mountpoint }}"
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
      "max": 100,
      "min": 0,
      "unit": "none"
    }
  },

  // options
  "options": {
  }
};
// }}}

// {{{ panelTopicPartitions
local panelTopicPartitions = {
  // type, title and description
  "type": "stat",
  "title": "Partitions",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "count(\n  count by (partition) (kafka_log_Log_Value{job=\"${job_jmx}\", topic=\"${topic}\", name=\"Size\"})\n)",
      "instant": true
    }
  ],

  // options
  "options": {
    "colorMode": "none",
  }
};
// }}}
// {{{ panelTopicSize
local panelTopicSize = {
  // type, title and description
  "type": "timeseries",
  "title": "Topic size",
  "description": "This panel displays size per broker. Please remember the \"actual\" size of the topic depends on number of partitions and replication count.",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum by (nodename) (kafka_log_Log_Value{job=\"${job_jmx}\", name=\"Size\", topic=\"${topic}\"})",
      "legendFormat": "{{ nodename }}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "unit": "bytes"
    }
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panelTopicMessages
local panelTopicMessages = {
  // type, title and description
  "type": "timeseries",
  "title": "Messages in / s",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum by (nodename) (rate(kafka_server_BrokerTopicMetrics_Count{job=\"${job_jmx}\", topic=\"${topic}\", name=\"MessagesInPerSec\"}[$__rate_interval]))",
      "legendFormat": "{{ nodename }}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "unit": "none"
    }
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panelTopicBytes
local panelTopicBytes = {
  // type, title and description
  "type": "timeseries",
  "title": "Bytes / s",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum by (nodename) (rate(kafka_server_BrokerTopicMetrics_Count{job=\"${job_jmx}\", topic=\"${topic}\", name=\"BytesInPerSec\"}[$__rate_interval]))",
      "legendFormat": "in {{ nodename }}"
    },
    {
      "expr": "sum by (nodename) (rate(kafka_server_BrokerTopicMetrics_Count{job=\"${job_jmx}\", topic=\"${topic}\", name=\"BytesOutPerSec\"}[$__rate_interval])) * -1",
      "legendFormat": "out {{ nodename }}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "unit": "bytes"
    }
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panelTopicRequests
local panelTopicRequests = {
  // type, title and description
  "type": "timeseries",
  "title": "Requests / s",
  "description": "`produce` and `fetch` requests per second",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum by (nodename) (rate(kafka_server_BrokerTopicMetrics_Count{job=\"${job_jmx}\", topic=\"${topic}\", name=\"TotalProduceRequestsPerSec\"}[$__rate_interval]))",
      "legendFormat": "produce {{ nodename }}"
    },
    {
      "expr": "sum by (nodename) (rate(kafka_server_BrokerTopicMetrics_Count{job=\"${job_jmx}\", topic=\"${topic}\", name=\"TotalFetchRequestsPerSec\"}[$__rate_interval])) * -1",
      "legendFormat": "fetch {{ nodename }}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "unit": "none"
    }
  },

  // options
  "options": {
  }
};
// }}}

// {{{ panelPerBrokerCPU
local panelPerBrokerCPU = {
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
      "expr": "sum(irate(node_cpu_seconds_total{mode=\"system\", job=\"${job_node}\", nodename=\"${nodename}\"}[$__rate_interval])) * 100",
      "legendFormat": "Busy System",
    },
    {
      "expr": "sum(irate(node_cpu_seconds_total{mode=\"user\", job=\"${job_node}\", nodename=\"${nodename}\"}[$__rate_interval])) * 100",
      "legendFormat": "Busy User",
    },
    {
      "expr": "sum(irate(node_cpu_seconds_total{mode=\"idle\", job=\"${job_node}\", nodename=\"${nodename}\"}[$__rate_interval])) * 100",
      "legendFormat": "Idle"
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
      },
      "unit": "short"
    }
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panelPerBrokerDiskSpace
local panelPerBrokerDiskSpace = {
  // type, title and description
  "type": "timeseries",
  "title": "Disk space used",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "node_filesystem_size_bytes{job=\"${job_node}\", nodename=\"${nodename}\"}",
      "legendFormat": "{{ mountpoint }} size"
    },
    {
      "expr": "node_filesystem_size_bytes{job=\"${job_node}\", nodename=\"${nodename}\"} - node_filesystem_avail_bytes{job=\"${job_node}\", nodename=\"${nodename}\"}",
      "legendFormat": "{{ mountpoint }} used"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "unit": "bytes"
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
.addTemplate(varJobNode)
.addTemplate(varJobJmx)
.addTemplate(varNodename)
.addTemplate(varTopic)

.addPanels(
  [
    grafana.row.new(title='Cluster', collapse=false) { gridPos: {x: 0, y: 0, w: 24, h: 1} },
    panelClusterBrokers     { gridPos: {x: 0,  y: 1, w: 4,  h: 8} },
    panelClusterTopics      { gridPos: {x: 4,  y: 1, w: 4,  h: 8} },
    panelClusterPartitions  { gridPos: {x: 8,  y: 1, w: 4,  h: 8} },
    panelClusterConnections { gridPos: {x: 12, y: 1, w: 12, h: 8} },

    panelClusterBytes     { gridPos: {x: 0,  y: 9,  w: 12, h: 8} },
    panelClusterRequests  { gridPos: {x: 12, y: 9,  w: 12, h: 8} },
    panelClusterCPU       { gridPos: {x: 0,  y: 17, w: 12, h: 8} },
    panelClusterDiskSpace { gridPos: {x: 12, y: 17, w: 12, h: 8} },

  ]
)

// {{{ row: Topic
.addPanel(
  grafana.row.new(title='Topic', collapse=true)
  .addPanels(
    [
      panelTopicPartitions { gridPos: {x: 0,  y: 26, w: 4,  h: 8} },
      panelTopicSize       { gridPos: {x: 4,  y: 26, w: 8,  h: 8} },
      panelTopicMessages   { gridPos: {x: 12, y: 26, w: 12, h: 8} },
      panelTopicBytes      { gridPos: {x: 0,  y: 34, w: 12, h: 8} },
      panelTopicRequests   { gridPos: {x: 12, y: 34, w: 12, h: 8} },
    ]
  ),
  gridPos={x: 0, y: 25, w: 24, h: 1},
)
// }}}
// {{{ row: CPU & Disk (per broker)
.addPanel(
  grafana.row.new(title='CPU & Disk (per broker)', collapse=true)
  .addPanels(
    [
      panelPerBrokerCPU       { gridPos: {x: 0,  y: 27, w: 12, h: 8} },
      panelPerBrokerDiskSpace { gridPos: {x: 12, y: 27, w: 12, h: 8} },
    ]
  ),
  gridPos={x: 0, y: 26, w: 24, h: 1},
)
// }}}
