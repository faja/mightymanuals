api docs:
- [panel stat](https://grafana.github.io/grafonnet/API/panel/stat/index.html)
- [prometheus query](https://grafana.github.io/grafonnet/API/query/prometheus.html)


### simple: single valie, instant query, color value
```
g.panel.stat.new('Number of nodes')
// if we are using util.grid.makeGrid() function withGridPos is not needed
//+ g.panel.stat.panelOptions.withGridPos(h=4, w=8, x=8, y=2)
+ g.panel.stat.queryOptions.withTargets([
    g.query.prometheus.new(
      '${PROMETHEUS_DS}',
      'count(up{infra_cluster="${infra_cluster}", namespace="${namespace}", vault_cluster="${vault_cluster}"})'
    ) + g.query.prometheus.withInstant(true),
  ]),
```

### value mapping - custom text based on query value
```
g.panel.stat.new('Cluster state')
// if we are using util.grid.makeGrid() function withGridPos is not needed
//+ g.panel.stat.panelOptions.withGridPos(h=4, w=8, x=0, y=2)
+ g.panel.stat.options.withColorMode("background")
+ g.panel.stat.standardOptions.withMappings([
    {
      type: 'value',
      options: {
        '0': { text: 'unhealthy', color: 'red'},
        '1': { text: 'healthy',   color: 'green'},
      }
    }
  ])
+ g.panel.stat.queryOptions.withTargets([
    g.query.prometheus.new(
      '${PROMETHEUS_DS}',
      'vault_autopilot_healthy{namespace="${namespace}", vault_cluster="${vault_cluster}"}'
    ) + g.query.prometheus.withInstant(true),
  ])
```

### text from label
the trick here is to use text mode "name" and legent format {{ label }}
```
g.panel.stat.new('Leader')
// if we are using util.grid.makeGrid() function withGridPos is not needed
//+ g.panel.stat.panelOptions.withGridPos(h=4, w=8, x=16, y=2)
+ g.panel.stat.options.withColorMode("none")
+ g.panel.stat.options.withGraphMode("none")
+ g.panel.stat.options.withTextMode("name")
+ g.panel.stat.queryOptions.withTargets([
    g.query.prometheus.new(
      '${PROMETHEUS_DS}',
      'vault_core_active{infra_cluster="namespace="${namespace}", vault_cluster="${vault_cluster}"} == 1'
    ) + g.query.prometheus.withInstant(true)
      + g.query.prometheus.withLegendFormat('{{job}}')
  ]),
```

other example with transformation
```
g.panel.stat.new('Version')
+ g.panel.stat.panelOptions.withDescription("[vault releases](https://github.com/hashicorp/vault/releases)")
+ g.panel.stat.options.withColorMode("none")
+ g.panel.stat.options.withGraphMode("none")
+ g.panel.stat.options.withTextMode("name")
+ g.panel.stat.queryOptions.withTargets([
    g.query.prometheus.new(
      '${PROMETHEUS_DS}',
      'container_last_seen{infra_cluster="${infra_cluster}", container_label_nomad_namespace="${namespace}", container_label_nomad_job_name="${vault_cluster}-1"}'
    )
    + g.query.prometheus.withInstant(true)
    + g.query.prometheus.withLegendFormat('{{image}}'),
  ])
  + g.panel.stat.queryOptions.withTransformations([
      g.panel.stat.queryOptions.transformation.withId('merge'),
      g.panel.stat.queryOptions.transformation.withId('renameByRegex')
      + g.panel.stat.queryOptions.transformation.withOptions({
          regex: '.+:(.+)-.+',
          renamePattern: '$1',
        }),
  ])
```

# old
- copy paste example, single value latest + graph
```
local panelStorageSize = {
  // type, title and description
  "type": "stat",
  "title": "Storage size",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "prometheus_tsdb_storage_blocks_bytes{job=\"$job\"}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "light-red",
        "mode": "fixed"
      },
      "unit": "bytes"
    }
  },

  // options
  "options": {
    "colorMode": "none",  // disable color
    "reduceOptions": {
      "calcs": [
        "lastNotNull"
      ]
    }
  }
};
```

- single stat, avare value across all metrics
```
// INFO
// the way to do it is:
//   - use transformation reduce (calculation does not matter)
//   - use options.reduceOptions.calcs: mean (this calculates avarerage)

local panelJobsAvgDuration = {
  // type, title and description
  "type": "stat",
  "title": "Avg duration",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "kube_job_status_completion_time{namespace=~\"$namespace\"} - kube_job_status_start_time{namespace=~\"$namespace\"}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "unit": "s"
    }
  },

  // options
  "options": {
    "reduceOptions": {
      "calcs": [
        "mean"
      ]
    }
  },

  // transformations
  "transformations": [
    {
      "id": "reduce"
    }
  ]
};
```

- single stat, merge multiple values into one single stat, for instance for displaying a version
```
    local panelClusterVersion = {
  // type, title and description
  "type": "stat",
  "title": "Cluster version",
  "description": "Actually a `kubelet` version running on a node, selected by `Last*`.",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "kube_node_info",
      "instant": true,
      "legendFormat": "{{ kubelet_version }}"
    }
  ],

  // filedConfig
  "fieldConfig": {
  },

  // options
  "options": {
    "textMode": "name",   // display text from label
    "colorMode": "none",  // disable color
    "reduceOptions": {
      "calcs": [
        "lastNotNull"
      ]
    }
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
        "regex": "v([^-]+)-.+",
        "renamePattern": "$1"
      }
    }
  ]
};
```
