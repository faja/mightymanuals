```
local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

local variables = [];
local panels = [];

// https://grafana.github.io/grafonnet/API/dashboard/index.html
g.dashboard.new('my-awesome-dashboard')
+ g.dashboard.withEditable(true)
+ g.dashboard.withUid('my-awesome-dashboard')
+ g.dashboard.withTags(['tag1', 'tag2'])
+ g.dashboard.withTimezone('UTC')
+ g.dashboard.time.withFrom('now-1h')
+ g.dashboard.time.withTo('now')
+ g.dashboard.graphTooltip.withSharedCrosshair()
+ g.dashboard.withVariables(variables)
+ g.dashboard.withPanels(panels)
```
