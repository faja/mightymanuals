
TODO

- collapsed
```
.addPanel(
  grafana.row.new(title='XXX', collapse=true)
  .addPanels(
    [
      panelLocalVar2 { gridPos: {x: 0,  y: 10, w: 8, h: 8} },
    ]
  ),
  gridPos={x: 0, y: 9, w: 24, h: 1},
)
```
- collapsed, repeatable rows
```
.addPanel(
  grafana.row.new(title='More stuff', collapse=true)
  .addPanels(
    [
      ...
    ]
  ),
  gridPos={x: 0, y: 21, w: 24, h: 1},
)
```

```
// also for multi value variable to used for this
local varBackend = grafana.template.custom(
    'backend',           // name
    'backend1,backend2', // query
    'All',               // current
    includeAll=true,
    hide=true,
);↴
```

- NONcollapsed
```
.addPanels(
    [
        grafana.row.new(title='Overview', collapse=false) { gridPos: {x: 0, y: 2, w: 24, h: 1} },
        panelMemoryUsage { gridPos: {x: 0, y: 3, w: 24, h: 8} },
    ]
)
```

- NONcollapsed, repeatable rows
```
.addPanels(
    [
        grafana.row.new(title='Task: ${task}', repeat='task', collapse=false) { gridPos: {x: 0, y: 2, w: 24, h: 1} },
        panelMemoryUsage { gridPos: {x: 0, y: 3, w: 24, h: 8} },
    ]
)
```
