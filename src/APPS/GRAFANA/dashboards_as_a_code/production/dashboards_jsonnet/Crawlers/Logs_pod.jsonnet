local grafana = import 'grafonnet/grafana.libsonnet';

local dashboard = grafana.dashboard.new(
  'Logs (pod)',
  timezone='utc',
  time_from='now-3h',
  editable=false,
);

# {{{ variables
local varLokiDS = grafana.template.datasource(
  'LOKI_DS', // name
  'loki',    // query
  'loki',    // current
  hide=true, // ''      - disables hiding at all, everything is displayed
             // 'label' - hide the name of the variable, and the drop down is displayed
             // any other value - hides everything
  //regex='/loki/',
);

local varNamespace = grafana.template.custom(
  'namespace', // name
  'crawlers',  // query
  'crawlers',  // current
  hide=true,
);

local varPod = grafana.template.text(
  'pod', // name
);
# }}}

// {{{ panelLogs
local panelLogs = {
  // type, title and description
  "type": "logs",
  "title": "Press `x` to explore.",

  // datasource
  "datasource": {
    "type": "loki",
    "uid": "${LOKI_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "{namespace=\"${namespace}\", app=\"airflow\", component=\"task\", pod=\"${pod}\"}",
    }
  ]
};
// }}}

dashboard
.addTemplate(varLokiDS)
.addTemplate(varNamespace)
.addTemplate(varPod)

.addPanels(
  [
    panelLogs { gridPos: {x: 0, y: 0, w: 24, h: 24} },
  ]
)
