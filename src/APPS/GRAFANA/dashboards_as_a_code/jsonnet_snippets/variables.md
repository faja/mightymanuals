### how to variables

```
// define variables local var
local variables = [
  ...
];

// add them to the dashboards
g.dashboard.new('my-awesome-dashboard')
+ g.dashboard.withVariables(variables)
```

### datasource
```
// https://grafana.github.io/grafonnet/API/dashboard/variable.html#obj-datasource
g.dashboard.variable.datasource.new('PROMETHEUS_DS', 'prometheus')
+ g.dashboard.variable.datasource.withRegex('/^prometheus$/')
+ g.dashboard.variable.datasource.generalOptions.showOnDashboard.withNothing()

g.dashboard.variable.datasource.new('LOKI_DS', 'loki')
+ g.dashboard.variable.datasource.withRegex('/^loki$/')
+ g.dashboard.variable.datasource.generalOptions.showOnDashboard.withNothing()
```

### constant
```
// https://grafana.github.io/grafonnet/API/dashboard/variable.html#obj-constant
g.dashboard.variable.constant.new('namespace', 'monitoring')
+ g.dashboard.variable.constant.generalOptions.showOnDashboard.withNothing()
```

### multi value constant
```
// https://grafana.github.io/grafonnet/API/dashboard/variable.html#obj-custom
g.dashboard.variable.custom.new('jobs', ['job-A', 'job-B', 'job-C'])
+ g.dashboard.variable.custom.generalOptions.withLabel('JoB: ')
+ g.dashboard.variable.custom.generalOptions.showOnDashboard.withLabelAndValue()
+ g.dashboard.variable.custom.selectionOptions.withMulti()
+ g.dashboard.variable.custom.selectionOptions.withIncludeAll()

// note to have a few values, and select them all by default,
// to use it with repeat for example, use `withCurrent` function
```

### input text variable (with optional default)
```
// https://grafana.github.io/grafonnet/API/dashboard/variable.html#obj-textbox
g.dashboard.variable.textbox.new('pod', default='__your_pod_name__')
```

### promethes/label query
```
// https://grafana.github.io/grafonnet/API/dashboard/variable.html#obj-query
g.dashboard.variable.query.new('infra_cluster')
+ g.dashboard.variable.query.withDatasource('prometheus', '${PROMETHEUS_DS}')
+ g.dashboard.variable.query.queryTypes.withLabelValues('infra_cluster', 'up{team="${team}", namespace="${namespace}", vault_cluster="${vault_cluster}"}')
+ g.dashboard.variable.query.refresh.onTime()

// NOTE: withLabelValues is using label_values() prometheus function

// NOTE: refresh.onTime() - when time range change
//       refresh.onLoad() - when dashboard loads
```
