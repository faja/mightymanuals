local grafana = import 'grafonnet/grafana.libsonnet';

local dashboard = grafana.dashboard.new(
  'Dags-sync',
  timezone='utc',
  time_from='now-6h',
  editable=false,
);

// {{{ variables
local varPrometheusDS = grafana.template.datasource(
  'PROMETHEUS_DS',     // name
  'prometheus',        // query
  'prometheus',        // current
  hide=true,           // ''      - disables hiding at all, everything is displayed
                       // 'label' - hide the name of the variable, and the drop down is displayed
                       // any other value - hides everything
  //regex='/prometheus/',
);

local varLokiDS = grafana.template.datasource(
  'LOKI_DS',     // name
  'loki',        // query
  'loki',        // current
  hide=true,     // ''      - disables hiding at all, everything is displayed
                 // 'label' - hide the name of the variable, and the drop down is displayed
                 // any other value - hides everything
  //regex='/loki/',
);

local varNamespace = grafana.template.custom(
  'namespace',    // name
  'airflow',  // query
  'airflow',  // current
  hide=true,
);
// }}}

// {{{ panelImageTag
local panelImageTag = {
  // type, title and description
  "type": "stat",
  "title": "Image tag",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "kube_pod_init_container_info{namespace=\"${namespace}\", pod=~\"dags-sync.*\"}",
      "legendFormat": "{{ image }}",
      "instant": true
    }
  ],

  // fieldConfig
  "fieldConfig": {
  },

  // options
  "options": {
    "textMode": "name",
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
        "regex": ".*:(.*)",
        "renamePattern": "$1"
      }
    }
  ]
};
// }}}
// {{{ panelLastDeploy
local panelLastDeploy = {
  // type, title and description
  "type": "stat",
  "title": "Last deploy",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "min(time()- container_start_time_seconds{namespace=\"${namespace}\", pod=~\"dags-sync.*\", container=\"\"})",
      "instant": true,
    }
  ],

  // fieldConfig
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
// {{{ panelLogs
local panelLogs = {
  // type, title and description
  "type": "logs",
  "title": "Logs",

  // datasource
  "datasource": {
    "type": "loki",
    "uid": "${LOKI_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "{app=\"argocd-image-updater\"} |= \"Setting new image\"",
    }
  ],

//  "options": {
//    "showTime": false,
//    "showLabels": false,
//    "showCommonLabels": false,
//    "wrapLogMessage": false,
//    "prettifyLogMessage": false,
//    "enableLogDetails": true,
//    "dedupStrategy": "none",
//    "sortOrder": "Descending"
//  }
};
// }}}

dashboard
.addTemplate(varPrometheusDS)
.addTemplate(varLokiDS)
.addTemplate(varNamespace)

.addPanels(
  [
    panelImageTag   { gridPos: {x: 0, y: 0, w: 6,  h: 5}  },
    panelLastDeploy { gridPos: {x: 0, y: 5, w: 6,  h: 5}  },
    panelLogs       { gridPos: {x: 6, y: 0, w: 18, h: 10} },
  ]
)
