local grafana = import 'grafonnet/grafana.libsonnet';

local dashboard = grafana.dashboard.new(
  'Events worker',
  timezone='utc',
  time_from='now-12h',
  editable=false,
);

# {{{ variables
local varPrometheusDS = grafana.template.datasource(
  'PROMETHEUS_DS',     // name
  'prometheus',        // query
  'prometheus',        // current
  hide=true,           // ''      - disables hiding at all, everything is displayed
                       // 'label' - hide the name of the variable, and the drop down is displayed
                       // any other value - hides everything
  //regex='/prometheus/',
);

local varNamespace = grafana.template.custom(
  'namespace',    // name
  'core-celery',  // query
  'core-celery',  // current
  hide=true,
);

local varWorkerName = grafana.template.custom(
  'worker_name',  // name
  'ats',          // query
  'ats',          // current
  hide=true,
);

local varVHost = grafana.template.custom(
  'vhost',  // name
  'core',   // query
  'core',   // current
  hide=true,
);

local varQueue = grafana.template.custom(
  'queue',  // name
  'handle_event,handle_event_applicationcreated,handle_event_assignapplicationtosession,handle_event_assignclicktosession,handle_event_assigncustomeventtosessionuuidbased,handle_event_assignimpressiontosession,handle_event_assignviewtosessionuuidbased,handle_event_clickcreated,handle_event_customeventcreateduuidbased,handle_event_impressioncreated,handle_event_vacancychange,handle_event_viewcreateduuidbased,handle_event_vacancycreate,handle_event_createcustomer,handle_event_createpartner,handle_event_changepricetagcorrection,handle_event_createpricetagcorrection,handle_event_clickcreateduuidbased,handle_event_assignclicktosessionuuidbased,handle_event_applicationcreateduuidbased,handle_event_assignapplicationtosessionuuidbased,handle_event_impressioncreateduuidbased,handle_event_assignimpressiontosessionuuidbased,handle_event_pageviewcreated,handle_event_assignpageviewtosession,handle_event_validatevacancies,handle_event_domainuidregexrecalculation,handle_event_singleapplicationadjustment,reassign_vacancy_for_app,reassign_vacancy_for_impression,reassign_vacancy_for_view,reassign_vacancy_for_custom_event',  //  query
  'All',  // current
  includeAll=true,
  multi=true,
);
# }}}

# {{{ panels
# {{{ panel: Workers (pods)
local panelWorkers = {
  // type, title and description
  "type": "stat",
  "title": "Workers (pods)",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(kube_pod_status_phase{namespace=\"$namespace\", phase=\"Running\", pod=~\"${namespace}-${worker_name}-worker-.+\"})",
      "instant": true
    }
  ],

  // options
  "options": {
    "colorMode": "none",
  }
};
# }}}
# {{{ panel: Consumers
local panelConsumers = {
  // type, title and description
  "type": "stat",
  "title": "Consumers",
  "description": "Number (sum) of consumers across all selected queues.",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(rabbitmq_queue_consumers{queue=~\"${queue}\"})",
      "instant": true
    }
  ],

  // options
  "options": {
    "colorMode": "none",
  }
};
# }}}
# {{{ panel: Queue(s) length
local panelQueueLength = {
  // type, title and description
  "type": "timeseries",
  "title": "Queue(s) length",
  "description": "Number of messages `ready`  and `unacknowledged`.",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(rabbitmq_queue_messages{vhost=\"${vhost}\", queue=~\"${queue}\"})",
      "legendFormat": "queue(s) length"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "fixed",
        "fixedColor": "super-light-blue"
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
# }}}
# {{{ panel: Queue(s) idle time 
local panelQueueIdleTime = {
  // type, title and description
  "type": "stat",
  "title": "Queue(s) idle time",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "time() - rabbitmq_queue_idle_since_seconds{queue=~\"${queue}\"}",
      "instant": true,
    }
  ],

  // fieldConfig
  "fieldConfig": {
    "defaults": {
      "unit": "s"
    },
  }
};
# }}}
# {{{ panel: Errors in last 24h 
local panelErrors = {
  // type, title and description
  "type": "stat",
  "title": "Errors in last 24h",
  "description": "Sum of `messages redelivered` and  `messages returned (unroutable)`",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(increase(rabbitmq_queue_messages_redelivered_total{queue=~\"${queue}\"}[24h]))\n+\nsum(increase(rabbitmq_queue_messages_returned_total{queue=~\"${queue}\"}[25h]))",
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
            "color": "green",
            "value": null
          },
          {
            "color": "red",
            "value": 1
          }
        ]
      }
    }
  },

  // options
  // "options": {
  // }
};
# }}}
# {{{ panel: Messages published / s
local panelMessagesPublished = {
  // type, title and description
  "type": "timeseries",
  "title": "Messages published / s",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(rate(rabbitmq_queue_messages_published_total{queue=~\"${queue}\"}[$__rate_interval]))",
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "fixed",
        "fixedColor": "#55dc4b"
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
# }}}
# {{{ panel: Messages delivered / s 
local panelMessagesDelivered = {
  // type, title and description
  "type": "timeseries",
  "title": "Messages delivered / s",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(rate(rabbitmq_queue_messages_delivered_total{queue=~\"${queue}\"}[$__rate_interval]))",
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "fixed",
        "fixedColor": "#de3fe7"
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
# }}}
# }}}

dashboard
.addTemplate(varPrometheusDS)
.addTemplate(varNamespace)
.addTemplate(varWorkerName)
.addTemplate(varVHost)
.addTemplate(varQueue)
.addPanels(
  [
    panelWorkers   { gridPos: {x: 0, y: 0, w: 2, h: 4} },
    panelConsumers { gridPos: {x: 0, y: 4, w: 2, h: 4} },

    panelQueueLength { gridPos: {x: 2, y: 0, w: 18, h: 8} },

    panelQueueIdleTime { gridPos: {x: 20, y: 0, w: 2, h: 8} },
    panelErrors        { gridPos: {x: 22, y: 0, w: 2, h: 8} },

    panelMessagesPublished { gridPos: {x: 0,  y: 8, w: 12, h: 8} },
    panelMessagesDelivered { gridPos: {x: 12, y: 8, w: 12, h: 8} },
  ]
)
