- copy paste point of start
```
// import full grafana jsonnet lib
local grafana = import 'grafonnet/grafana.libsonnet';

// create local dashboard variable
local dashboard = grafana.dashboard.new(
  'K8S / Pod system stats', // first argument is the name of the dashboard
  timezone='utc',
  time_from='now-3h',
  editable=false,
};

// next I put variables (grafana templates)
// {{{ dashboard variables/templates
// prometheus
local varPrometheusDS = grafana.template.datasource(
  'PROMETHEUS_DS', // name
  'prometheus',    // query
  'prometheus',    // current
  hide=true,       // ''      - disables hiding at all, everything is displayed
                   // 'label' - hide the name of the variable, and the drop down is displayed
                   // any other value - hides everything
  //regex='/prometheus/',
);

// loki
local varLokiDS = grafana.template.datasource(
  'LOKI_DS', // name
  'loki',    // query
  'loki',    // current
  hide=true, // ''      - disables hiding at all, everything is displayed
             // 'label' - hide the name of the variable, and the drop down is displayed
             // any other value - hides everything
  //regex='/loki/',
);

// constant
local varJob = grafana.template.custom(
  'job',        // name
  'prometheus', // query
  'prometheus', // current
  hide=true,
);

// label query
local varNamespace = std.mergePatch(
  grafana.template.new(
    'namespace',                                       // name
    {"type": "prometheus", "uid": "${PROMETHEUS_DS}"}, // datasource
    "label_values(kube_namespace_created, namespace)", // query
    current='default',
  ),
  {
    "definition": "label_values(kube_namespace_created, namespace)",
  }
);

// text box
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

// then I put panels definitions
// {{{ panels
// }}}

dashboard
.addTemplate(varPrometheusDS)
.addTemplate(varPod)
// and all other variables you need

// attach panels

// first if we need just panels go for something like:
.addPanels(
  [
    panelStatAge            { gridPos: {x: 0, y: 0, w: 2, h: 4} },
    panelStatAge            { gridPos: {x: 0, y: 0, w: 2, h: 4} },
    panelStatAge            { gridPos: {x: 0, y: 0, w: 2, h: 4} },
  ]
)

// if you need "OPENED" row
.addPanels(
  [
    grafana.row.new(title='Overview', collapse=false) { gridPos: {x: 0, y: 0, w: 24, h: 1} },
    panelOverviewConnectors { gridPos: {x: 0, y: 1, w: 2, h: 4} },
    panelOverviewTasks      { gridPos: {x: 2, y: 1, w: 2, h: 4} },
  ]
)

// if you need "CLOSED" row
.addPanel(
  grafana.row.new(title='Internal: Process and Scrape Info', collapse=true)
  .addPanels(
    [
      panelInternalScrapes       { gridPos: {x: 0,  y: 18, w: 8,  h: 8} },
      panelInternalHttpResponses { gridPos: {x: 8,  y: 18, w: 8,  h: 8} },
    ]
  ),
  gridPos={X: 0, y: 17, w: 24, h: 1},
)
```
