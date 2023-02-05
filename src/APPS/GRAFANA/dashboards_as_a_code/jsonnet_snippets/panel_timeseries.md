- copy paste example
```
local panelCPUUsage = {
  // type, title and description
  "type": "timeseries",
  "title": "CPU usage",
  "description": "blabla...",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "irate(process_cpu_seconds_total{job=\"$job\"}[$__rate_interval])",
      "legendFormat": "cpu usage",
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "semi-dark-purple",
        "mode": "fixed"
      },
      "custom": {
        "fillOpacity": 6
      },
      "min": 0,
      "unit": "s"
    }
  },

  // options
  "options": {
    "legend": {
      "displayMode": "hidden"
    }
  }
};
```

- section explained
```
local panelSomeTimeSeriesPanel = {
  // for timeseries panel json we do have following top level sections
  "title":         (string)
  "type":          (string)
  "datasource":    (map)
  "targets":       (list)
  "fieldConfig":   (map)
  "options":       (map)

  // title
  "title": "dashboard title"

  // type
  "type": "timeseries" // for timeseries it is always "timeseries" :P

  // datasource
  "datasource": {
    "type": "prometheus",     // for prometheus it is prometheus
    "uid": "${PROMETHEUS_DS}" // if we are using variable
  }

  // targets - list of targets
  //   each target is a map containing at least "expr" and "legendFormat"
  "targets": [
    {
      "expr": "prometheus query goes here",  // prometheus query
      "legendFormat": "{{ node_ip }}"        // legent to be desplayed
    }
  ]

  // options - for now I only find it useful to set legent hidden and legen location
  //           you can also set tooltip option here, but I never do this
  // IMPORTANT, even you do nothing with the legend, options section must be there - EVEN EMPTY!
  // options
  "options": {
    "legend": {
      "displayMode": "hidden"
    }
  }

  // fieldConfig - biggest section, so I'll split it into subsections
  //               main section contains: "defaults" and "overrides"
  "fieldConfig": {
    "defaults":  (map)
    "overrides": (list)
  }

  // fieldConfig.defaults - config for:
  //                          - unit
  //                          - decimals
  //                          - min (and max) values
  //                          - color
  //                          - custom.fillOpacity
  //                          - custom.lineWidth
  //                          - custom.drawStyle
  "fieldConfig": {
    "defaults": {
      "unit": "short",
      "min": 0,
      "decimals": 2,
      "color": {
        "mode": "fixed",
        "fixedColor": "light-blue"
      },
      "custom": {
        "fillOpacity": 8,
        "lineWidth": 2,
        "drawStyle": "bars"
      }
    }
  }

  // filedConfig.overrides - config for overrides
  //   this is a list of single override which is a map containing:
  //     - "matcher"    (map)
  //     - "properties" (list)
  "fieldConfig": {
    "overrides": [
      {
        "matcher": {
          "id": "byName",
          "options": "chunks created"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "dark-green",
              "mode": "fixed"
            }
          }
        ]
      }
    ]
};
```
