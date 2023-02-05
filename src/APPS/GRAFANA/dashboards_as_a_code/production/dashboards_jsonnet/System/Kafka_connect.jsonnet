local grafana = import 'grafonnet/grafana.libsonnet';

local dashboard = grafana.dashboard.new(
  'Kafka Connect',
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

local varConnector = std.mergePatch(
  grafana.template.new(
    'connector',                                                        // name
    {"type": "prometheus", "uid": "${PROMETHEUS_DS}"},                  // datasource
    "label_values(cp_kafka_connect_connector_task_metrics, connector)", // query
  ),
  {
    "definition": "label_values(cp_kafka_connect_connector_task_metrics, connector)",
  }
);
// }}}

// {{{ panels
// {{{ panelOverviewConnectors
local panelOverviewConnectors = {
  // type, title and description
  "type": "stat",
  "title": "Connectors",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "cp_kafka_connect_connect_worker_metrics_connector_count",
      "instant": true
    }
  ]
};
// }}}
// {{{ panelOverviewTasks
local panelOverviewTasks = {
  // type, title and description
  "type": "stat",
  "title": "Tasks",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "cp_kafka_connect_connect_worker_metrics_task_count",
      "instant": true
    }
  ]
};
// }}}
// {{{ panelSinkTasks
local panelSinkTasks = {
  // type, title and description
  "type": "stat",
  "title": "Tasks running",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(cp_kafka_connect_connector_task_metrics{connector=\"$connector\", status=\"running\"})",
      "legendFormat": "{{ connector }}",
      "instant": true
    }
  ]
};
// }}}
// {{{ panelSinkRecords
local panelSinkRecords = {
  // type, title and description
  "type": "timeseries",
  "title": "Records / s",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(rate(cp_kafka_connect_sink_task_metrics_sink_record_send_total{connector=\"${connector}\"}[$__rate_interval]))",
      "legendFormat": "send"
    },
    {
      "expr": "sum(rate(cp_kafka_connect_sink_task_metrics_sink_record_read_total{connector=\"${connector}\"}[$__rate_interval])) * -1",
      "legendFormat": "read"
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
// {{{ panelSinkBatchTime
local panelSinkBatchTime = {
  // type, title and description
  "type": "timeseries",
  "title": "Avg put batch time",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "cp_kafka_connect_sink_task_metrics_put_batch_avg_time_ms{connector=\"${connector}\"}",
      "legendFormat": "task:{{ task }}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "unit": "ms"
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
.addTemplate(varConnector)

.addPanels(
  [
    grafana.row.new(title='Overview', collapse=false) { gridPos: {x: 0, y: 0, w: 24, h: 1} },
    panelOverviewConnectors { gridPos: {x: 0, y: 1, w: 2, h: 4} },
    panelOverviewTasks      { gridPos: {x: 2, y: 1, w: 2, h: 4} },
  ]
)

.addPanels(
  [
    grafana.row.new(title='Sink connectors', collapse=false) { gridPos: {x: 0, y: 5, w: 24, h: 1} },
    panelSinkTasks     { gridPos: {x: 0,  y: 6, w: 4,  h: 8} },
    panelSinkRecords   { gridPos: {x: 4,  y: 6, w: 10, h: 8} },
    panelSinkBatchTime { gridPos: {x: 14, y: 6, w: 10, h: 8} },
  ]
)

.addPanels(
  [
    grafana.row.new(title='Source connectors', collapse=false) { gridPos: {x: 0, y: 14, w: 24, h: 1} },
  ]
)
