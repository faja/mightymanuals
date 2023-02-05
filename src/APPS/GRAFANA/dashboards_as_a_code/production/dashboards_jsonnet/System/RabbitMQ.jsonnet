local grafana = import 'grafonnet/grafana.libsonnet';

local dashboard = grafana.dashboard.new(
  'RabbitMQ',
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

local varCluster = std.mergePatch(
  grafana.template.new(
    'cluster',                                         // name
    {"type": "prometheus", "uid": "${PROMETHEUS_DS}"}, // datasource
    "label_values(rabbitmq_version_info, cluster)",    // query
  ),
  {
    "definition": "label_values(rabbitmq_version_info, cluster)"
  }
);
// }}}

// {{{ panels
// {{{ panel: Version
local panelVersion = {
  // type, title and description
  "type": "stat",
  "title": "Version",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "rabbitmq_version_info{cluster=\"${cluster}\"}",
      "instant": true,
      "legendFormat": "{{ rabbitmq }}"
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
// }}}
// {{{ panel: Nodes
local panelNodes = {
  // type, title and description
  "type": "stat",
  "title": "Nodes",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "count(rabbitmq_uptime{cluster=\"$cluster\"})",
      "instant": true
    }
  ],

  // filedConfig
  "fieldConfig": {
  },

  // options
  "options": {
    "colorMode": "none",  // disable color
    "graphMode": "none",  // disable graphing values (for instant query it does not matter)
    "reduceOptions": {
      "calcs": [
        "lastNotNull"
      ]
    }
  }
};
// }}}
// {{{ panel: Nodes uptime
local panelNodesUptime = {
  // type, title and description
  "type": "stat",
  "title": "Nodes uptime",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "rabbitmq_uptime{cluster=\"$cluster\"}",
      "instant": true,
      "legendFormat": "{{ node }}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "unit": "ms"
    }
  },

  // options
  "options": {
    "textMode": "value",  // display value only
    "colorMode": "none",  // disable color
    "graphMode": "none",  // disable graphing values (for instant query it does not matter)
    "reduceOptions": {
      "calcs": [
        "lastNotNull"
      ]
    }
  }
};
// }}}
// {{{ panel: Vhosts
local panelVhosts = {
  // type, title and description
  "type": "stat",
  "title": "Vhosts",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "count(\n  count by (vhost) (rabbitmq_exchange_messages_published_in_total{cluster=\"$cluster\"})\n)",
      "instant": true
    }
  ],

  // filedConfig
  "fieldConfig": {
  },

  // options
  "options": {
    "colorMode": "none",  // disable color
    "graphMode": "none",  // disable graphing values (for instant query it does not matter)
    "reduceOptions": {
      "calcs": [
        "lastNotNull"
      ]
    }
  }
};
// }}}
// {{{ panel: Exchanges
local panelExchanges = {
  // type, title and description
  "type": "stat",
  "title": "Exchanges",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "rabbitmq_exchanges{cluster=\"$cluster\"}",
      "instant": true
    }
  ],

  // filedConfig
  "fieldConfig": {
  },

  // options
  "options": {
    "colorMode": "none",  // disable color
    "graphMode": "none",  // disable graphing values (for instant query it does not matter)
    "reduceOptions": {
      "calcs": [
        "lastNotNull"
      ]
    }
  }
};
// }}}
// {{{ panel: Queues
local panelQueues = {
  // type, title and description
  "type": "stat",
  "title": "Queues",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "rabbitmq_queues{cluster=\"$cluster\"}",
      "instant": true
    }
  ],

  // filedConfig
  "fieldConfig": {
  },

  // options
  "options": {
    "colorMode": "none",  // disable color
    "graphMode": "none",  // disable graphing values (for instant query it does not matter)
    "reduceOptions": {
      "calcs": [
        "lastNotNull"
      ]
    }
  }
};
// }}}

// {{{ panel: Connections
local panelConnections = {
  // title and type
  "title": "Connections",
  "type": "timeseries",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "rabbitmq_connections{cluster=\"$cluster\"}"
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
        "fillOpacity": 12
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
// {{{ panel: Consumers
local panelConsumers = {
  // title and type
  "title": "Consumers",
  "type": "timeseries",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "rabbitmq_consumers{cluster=\"$cluster\"}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "super-light-blue",
        "mode": "fixed"
      },
      "custom": {
        "fillOpacity": 6
      },
      "min": 0,
      "unit": "short"
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
// {{{ panel: Messages published in
local panelMessagesPublishedIn = {
  // title and type
  "title": "Messages published in",
  "type": "timeseries",
  "description": "Total number of messages per second published in to the exchanges.",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(rate(rabbitmq_exchange_messages_published_in_total{cluster=\"$cluster\"}[$__rate_interval]))"
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
        "fillOpacity": 12
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
// {{{ panel: Messages published out
local panelMessagesPublishedOut = {
  // title and type
  "title": "Messages published out",
  "type": "timeseries",
  "description": "Total number of messages per second published out from the exchanges.",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(rate(rabbitmq_exchange_messages_published_out_total{cluster=\"$cluster\"}[$__rate_interval]))"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "super-light-yellow",
        "mode": "fixed"
      },
      "custom": {
        "fillOpacity": 12
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
// {{{ panel: Messages published in (per vhost)
local panelMessagesPublishedInPerVhost = {
  // title and type
  "title": "Messages published in",
  "type": "timeseries",
  "description": "Number of messages per second published in to the exchanges per vhost.",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum by (vhost) (rate(rabbitmq_exchange_messages_published_in_total{cluster=\"$cluster\"}[$__rate_interval]))",
      "legendFormat": "{{ vhost }}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 12
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
// {{{ panel: Messages published out (per vhost)
local panelMessagesPublishedOutPerVhost = {
  // title and type
  "title": "Messages published out",
  "type": "timeseries",
  "description": "Number of messages per second published out from the exchanges per vhost.",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum by (vhost) (rate(rabbitmq_exchange_messages_published_out_total{cluster=\"$cluster\"}[$__rate_interval]))",
      "legendFormat": "{{ vhost }}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 12
      }
    }
  },

  // options
  "options": {
  }
};
// }}}

// {{{ panel: Messages ready
local panelMessagesReady = {
  // title and type
  "title": "Messages ready",
  "type": "timeseries",
  "description": "Number of messages ready, across all vhosts, all queues.\n\nTo get top 10 queues with most number of messages ready:\n\n```topk(10, sum by (queue) rabbitmq_queue_messages_ready))```",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "rabbitmq_queue_messages_ready_global{cluster=\"$cluster\"}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "super-light-purple",
        "mode": "fixed"
      },
      "custom": {
        "fillOpacity": 12
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
// {{{ panel: Messages unacknowledged
local panelMessagesUnacknowledged = {
  // title and type
  "title": "Messages unacknowledged",
  "type": "timeseries",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "rabbitmq_queue_messages_unacknowledged_global{cluster=\"$cluster\"}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "super-light-blue",
        "mode": "fixed"
      },
      "custom": {
        "fillOpacity": 12
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

// {{{ panel: Node memory usage
local panelNodeMemoryUsage = {
  // title and type
  "title": "Node memory usage",
  "type": "timeseries",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum by (node) (rabbitmq_node_mem_limit{cluster=\"$cluster\"})",
      "legendFormat": "{{ node }} limit"
    },
    {
      "expr": "sum by (node) (rabbitmq_node_mem_used{cluster=\"$cluster\"})",
      "legendFormat": "{{ node }} usage"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "unit": "bytes"
    },
    "overrides": [
      {
        "matcher": {
          "id": "byRegexp",
          "options": "/limit/"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "light-red",
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
// {{{ panel: Disk free
local panelDiskFree = {
  // title and type
  "title": "Disk free",
  "type": "timeseries",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum by (node) (rabbitmq_node_disk_free{cluster=\"$cluster\"})",
      "legendFormat": "{{ node }}"
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
.addTemplate(varCluster)
.addPanels(
  [
    // row1
    panelVersion     { gridPos: {x: 0,  y: 0, w: 3, h: 4} },
    panelNodes       { gridPos: {x: 3,  y: 0, w: 3, h: 4} },
    panelNodesUptime { gridPos: {x: 6,  y: 0, w: 6, h: 4} },
    panelVhosts      { gridPos: {x: 12, y: 0, w: 3, h: 4} },
    panelExchanges   { gridPos: {x: 15, y: 0, w: 3, h: 4} },
    panelQueues      { gridPos: {x: 18, y: 0, w: 3, h: 4} },

    // row2
    panelConnections { gridPos: {x: 0,  y: 4, w: 12, h: 8} },
    panelConsumers   { gridPos: {x: 12, y: 4, w: 12, h: 8} },

    // row3
    panelMessagesPublishedIn          { gridPos: {x: 0,  y: 12, w: 6, h: 8} },
    panelMessagesPublishedOut         { gridPos: {x: 6,  y: 12, w: 6, h: 8} },
    panelMessagesPublishedInPerVhost  { gridPos: {x: 12, y: 12, w: 6, h: 8} },
    panelMessagesPublishedOutPerVhost { gridPos: {x: 18, y: 12, w: 6, h: 8} },

    // row4
    panelMessagesReady          { gridPos: {x: 0,  y: 20, w: 12, h: 8} },
    panelMessagesUnacknowledged { gridPos: {x: 12, y: 20, w: 12, h: 8} },

    // row5
    panelNodeMemoryUsage { gridPos: {x: 0,  y: 28, w: 12, h: 8} },
    panelDiskFree        { gridPos: {x: 12, y: 28, w: 12, h: 8} },
  ]
)
