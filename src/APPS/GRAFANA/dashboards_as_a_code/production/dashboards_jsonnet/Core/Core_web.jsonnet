local grafana = import 'grafonnet/grafana.libsonnet';

local dashboard = grafana.dashboard.new(
  'Core-web',
  timezone='utc',
  time_from='now-1h',
  editable=false,
);

// {{{ variables
local varLokiDS = grafana.template.datasource(
  'LOKI_DS',     // name
  'loki',        // query
  'loki',        // current
  hide=true,     // ''      - disables hiding at all, everything is displayed
                 // 'label' - hide the name of the variable, and the drop down is displayed
                 // any other value - hides everything
  //regex='/loki/',
);
// }}}

// {{{ panelRequests
local panelRequests = {
  // type, title and description
  "type": "timeseries",
  "title": "Requests / s",

  // datasource
  "datasource": {
    "type": "loki",
    "uid": "${LOKI_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum by (status) (rate({app=\"core-web\", container=\"nginx\"} \n  != \"ELB-HealthChecker\"\n  | pattern `<_> - - <_> \"<method> <_> <_>\" <status> <_> \"<_>\" \"<_>\" <duration>`\n[$__interval]))",
      "legendFormat": "{{ status }}"
    }
  ],

  // fieldConfig
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

dashboard
.addTemplate(varLokiDS)

.addPanels(
  [
    panelRequests { gridPos: {x: 0, y: 0, w: 24, h: 8}  },
  ]
)
