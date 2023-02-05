local grafana = import 'grafonnet/grafana.libsonnet';

local dashboard = grafana.dashboard.new(
  'Dashboard',
  timezone='utc',
  time_from='now-24h',
  editable=false,
);

# {{{ variables
local varPrometheusDS = grafana.template.datasource(
  'PROMETHEUS_DS', // name
  'prometheus',    // query
  'prometheus',    // current
  hide=true,       // ''      - disables hiding at all, everything is displayed
                   // 'label' - hide the name of the variable, and the drop down is displayed
                   // any other value - hides everything
  //regex='/prometheus/',
);

local varNamespace = grafana.template.custom(
  'namespace', // name
  'crawlers',  // query
  'crawlers',  // current
  hide=true,
);

local varDagId = grafana.template.custom(
  'dag_id',   // name
  'crawlers', // query
  'crawlers', // current
  hide=true,
);

local varTaskSoftTimeout = grafana.template.custom(
  'task_soft_timeout', // name
  '600',               // query
  '600',               // current
  hide=true,
);
# }}}

# {{{ panels
# {{{ panelStatTasks
local panelStatTasks = {
  // type, title and description
  "type": "stat",
  "title": "Tasks: running (current)",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(kube_pod_status_phase{namespace=\"${namespace}\", phase=\"Running\"})",
      "instant": true,
    }
  ],

  // fieldConfig
  "fieldConfig": {
    "defaults": {
      "mappings": [
        {
          "options": {
            "match": "null",
            "result": {
              "index": 0,
              "text": "0"
            }
          },
          "type": "special"
        }
      ],
      "thresholds": {
        "mode": "absolute",
        "steps": [
          {
            "color": "text",
            "value": null
          },
          {
            "color": "green",
            "value": 1
          },
          {
            "color": "super-light-yellow",
            "value": 10
          },
          {
            "color": "super-light-red",
            "value": 15
          }
        ]
      },
      "color": {
        "mode": "thresholds"
      }
    },
  },

  // options
  "options": {
    "colorMode": "none",
  }
};
# }}}
# {{{ panelStatOldestTask
local panelStatOldestTask = {
  // type, title and description
  "type": "stat",
  "title": "Oldest task",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "max(\n  time() - container_start_time_seconds{namespace=\"${namespace}\", container=\"\"}\n)",
      "instant": true
    }
  ],

  // fieldConfig
  "fieldConfig": {
    "defaults": {
      "mappings": [
        {
          "options": {
            "match": "null",
            "result": {
              "color": "text",
              "index": 0,
              "text": "No running tasks"
            }
          },
          "type": "special"
        }
      ],
      "thresholds": {
        "mode": "absolute",
        "steps": [
          {
            "color": "super-light-green",
            "value": null
          },
          {
            "color": "super-light-yellow",
            "value": 60
          },
          {
            "color": "super-light-red",
            "value": 300
          }
        ]
      },
      "color": {
        "mode": "thresholds"
      },
      "unit": "s"
    }
  }
};
# }}}
# {{{ panelStatNewestTask
local panelStatNewestTask = {
  // type, title and description
  "type": "stat",
  "title": "Newest task",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "min(\n  time() - container_start_time_seconds{namespace=\"${namespace}\", container=\"\"}\n)",
      "instant": true,
    }
  ],

  // fieldConfig
  "fieldConfig": {
    "defaults": {
      "mappings": [
        {
          "options": {
            "match": "null",
            "result": {
              "color": "text",
              "index": 0,
              "text": "No running tasks"
            }
          },
          "type": "special"
        }
      ],
      "thresholds": {
        "mode": "absolute",
        "steps": [
          {
            "color": "super-light-green",
            "value": null
          },
          {
            "color": "super-light-yellow",
            "value": 60
          },
          {
            "color": "super-light-red",
            "value": 300
          }
        ]
      },
      "color": {
        "mode": "thresholds"
      },
      "unit": "s"
    }
  }
};
# }}}
# {{{ panelTableLongest
local panelTableLongest = {
  // type, title and description
  "type": "table",
  "title": "Top 4 longest currently running tasks",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "topk(4, time() - container_start_time_seconds{namespace=\"${namespace}\", container=\"\"})",
      "format": "table",
      "instant": true
    }
  ],

  // transformations
  "transformations": [
    {
      "id": "filterFieldsByName",
      "options": {
        "include": {
          "names": [
            "pod",
            "Value"
          ]
        }
      }
    }
  ],

  // fieldConfig
  "fieldConfig": {
    "defaults": {
      "unit": "s"
    }
  }
};
# }}}
# {{{ panelExploreLogs
local panelExploreLogs = {
  "type": "dashlist",
  "title": "Explore logs",
  "options": {
    "showHeadings": false,
    "showSearch": true,
    "query": "Logs"
  }
};
# }}}
# {{{ panelDagDuration
local panelDagDuration = {
  // type, title and description
  "type": "timeseries",
  "title": "Dag duration",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "airflow_dagrun_duration{dag_id=\"${dag_id}\", quantile=\"0.99\"}",
      "legendFormat": "succeeded"
    },
    {
      "expr": "airflow_dagrun_failed{dag_id=\"${dag_id}\", quantile=\"0.99\"}",
      "legendFormat": "failed"
    }
  ],

  // fieldConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "fixed",
        "fixedColor": "super-light-green"
      },
      "custom": {
        "drawStyle": "bars",
        "lineWidth": 5
      },
      "min": 0,
      "unit": "s"
    },
    "overrides": [
      {
        "matcher": {
          "id": "byName",
          "options": "failed"
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
# }}}
# {{{ panelTasks
local panelTasks = {
  // type, title and description
  "type": "timeseries",
  "title": "Tasks",
  "description": "Based on pool",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "airflow_pool_running_slots_crawlers",
      "legendFormat": "running"
    },
    {
      "expr": "airflow_pool_queued_slots_crawlers",
      "legendFormat": "queued"
    }
  ],

  // fieldConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "fixed",
        "fixedColor": "#2dee14"
      },
      "custom": {
        "lineWidth": 2,
        "fillOpacity": 10,
      }
    },
    "overrides": [
      {
        "matcher": {
          "id": "byName",
          "options": "queued"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "#e82ee3",
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
# }}}
# {{{ panelLongTasks
local panelLongTasks = {
  // type, title and description
  "type": "timeseries",
  "title": "Long running tasks",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "airflow_task_duration{dag_id=\"$dag_id\", quantile=\"0.99\"} > ${task_soft_timeout}",
      "legendFormat": "{{ task_id }}"
    }
  ],

  // fieldConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "drawStyle": "bars",
        "lineWidth": 3,
      },
      "min": 0,
      "unit": "s"
    }
  },

  // options
  "options": {
  }
};
# }}}
# {{{ panelStatTasksSuccessed
local panelStatTasksSuccessed = {
  // type, title and description
  "type": "stat",
  "title": "Tasks successed",
  "description": "In a specified range.",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "round(\n  sum(increase(airflow_task_finish{dag_id=\"${dag_id}\", state=\"success\"}[$__range]))\n)",
      "instant": true
    }
  ],

  // fieldConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "fixed",
        "fixedColor": "super-light-green"
      }
    }
  }
};
# }}}
# {{{ panelStatTasksRetried
local panelStatTasksRetried = {
  // type, title and description
  "type": "stat",
  "title": "Tasks retried",
  "description": "In a specified range.",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "round(\n  sum(increase(airflow_task_finish{dag_id=\"${dag_id}\", state=\"up_for_retry\"}[$__range]))\n)",
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
        "mode": "absolute",
        "steps": [
          {
            "color": "super-light-green",
            "value": null
          },
          {
            "color": "super-light-yellow",
            "value": 10
          },
          {
            "color": "super-light-red",
            "value": 20
          }
        ]
      }
    }
  }
};
# }}}
# {{{ panelStatTasksSkipped
local panelStatTasksSkipped = {
  // type, title and description
  "type": "stat",
  "title": "Tasks skipped",
  "description": "In a specified range.",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "round(\n  sum(increase(airflow_task_finish{dag_id=\"${dag_id}\", state=\"skipped\"}[$__range]))\n)",
      "instant": true
    }
  ],

  // fieldConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "fixed",
        "fixedColor": "super-light-orange"
      }
    }
  }
};
# }}}
# {{{ panelStatTasksFailed
local panelStatTasksFailed = {
  // type, title and description
  "type": "stat",
  "title": "Tasks failed",
  "description": "In a specified range.",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "round(\n    sum(increase(airflow_task_finish{dag_id=\"${dag_id}\", state=\"failed\"}[$__range]))\n)",
      "instant": true,
    }
  ],

  // fieldConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "fixed",
        "fixedColor": "super-light-red"
      }
    }
  }
};
# }}}
# {{{ panelTableTasksFailed
local panelTableTasksFailed = {
  // type, title and description
  "type": "table",
  "title": "Tasks failed",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "round(increase(airflow_task_finish{dag_id=\"${dag_id}\", state=\"failed\"}[$__range])) > 0",
      "format": "table",
      "instant": true
    }
  ],

  // transformations
  "transformations": [
    {
      "id": "filterFieldsByName",
      "options": {
        "include": {
          "names": [
            "task_id",
            "Value"
          ]
        }
      }
    },
    {
      "id": "renameByRegex",
      "options": {
        "regex": "Value",
        "renamePattern": "# fails"
      }
    }
  ],

  // fieldConfig
  "fieldConfig": {
    "defaults": {
      "decimals": 0,
      "unit": "short"
    }
  },

  // options
  "options": {
    "sortBy": [
      {
        "desc": true,
        "displayName": "# fails"
      }
    ]
  }
};
# }}}
# }}}

dashboard
.addTemplate(varPrometheusDS)
.addTemplate(varNamespace)
.addTemplate(varDagId)
.addTemplate(varTaskSoftTimeout)

.addPanels(
  [
    panelStatTasks      { gridPos: {x: 0,  y: 0, w: 3,  h: 6} },
    panelStatOldestTask { gridPos: {x: 3,  y: 0, w: 3,  h: 3} },
    panelStatNewestTask { gridPos: {x: 3,  y: 3, w: 3,  h: 3} },
    panelTableLongest   { gridPos: {x: 6,  y: 0, w: 11, h: 6} },
    panelExploreLogs    { gridPos: {x: 17, y: 0, w: 7,  h: 6} },

    panelDagDuration { gridPos: {x: 0, y: 6,  w: 24, h: 8} },
    panelTasks       { gridPos: {x: 0, y: 14, w: 24, h: 8} },
    panelLongTasks   { gridPos: {x: 0, y: 22, w: 24, h: 8} },

    panelStatTasksSuccessed { gridPos: {x: 0,  y: 29, w: 3,  h: 8} },
    panelStatTasksRetried   { gridPos: {x: 3,  y: 29, w: 3,  h: 8} },
    panelStatTasksSkipped   { gridPos: {x: 6,  y: 29, w: 3,  h: 8} },
    panelStatTasksFailed    { gridPos: {x: 9,  y: 29, w: 3,  h: 8} },
    panelTableTasksFailed   { gridPos: {x: 12, y: 29, w: 12, h: 8} },
  ]
)
