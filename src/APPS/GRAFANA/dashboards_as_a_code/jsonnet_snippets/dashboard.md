```
local grafana = import 'grafonnet/grafana.libsonnet';

local dashboard = grafana.dashboard.new(
  'Prometheus',        // dashboard name
  timezone='utc',
  time_from='now-1h',
  editable=true,
  graphTooltip=1,
)

// ...

dashboard
.addTemplate(varPrometheusDS)
.addTemplate(varJob)
.addTemplate(varCluster)

// top row
.addPanels(
  [
    panelVersion     { gridPos: {x: 0,  y: 0, w: 3, h: 4} },
    panelNodes       { gridPos: {x: 3,  y: 0, w: 3, h: 4} },
  ]
)

// row ...
.addPanel(
  grafana.row.new(title='TSDB', collapse=true)
  .addPanels(
    [
      panelTSDBStorageSize        { gridPos: {x: 0,  y: 10, w: 8, h: 8} },
      panelTSDBSamplesAppended    { gridPos: {x: 8,  y: 10, w: 8, h: 8} },
    ]
  ),
  gridPos={X: 0, y: 9, w: 24, h: 1},
)
```
