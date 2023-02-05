local grafana = import 'grafonnet/grafana.libsonnet';

local dashboard = grafana.dashboard.new(
  'Prometheus',
  timezone='utc',
  time_from='now-6h',
  editable=false,
);

// {{{ dashboard variables/templates
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
  'LOKI_DS', // name
  'loki',    // query
  'loki',    // current
  hide=true, // ''      - disables hiding at all, everything is displayed
             // 'label' - hide the name of the variable, and the drop down is displayed
             // any other value - hides everything
  //regex='/loki/',
);

local varJob = grafana.template.custom(
  'job',        // name
  'prometheus', // query
  'prometheus', // current
  hide=true,
);
// }}}

// {{{ panels
// {{{ panels: top row
// {{{ panel: Version
local panelVersion = {
  // type, title and description
  "type": "stat",
  "title": "Version",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "prometheus_build_info{job=\"${job}\"}",
      "legendFormat": "{{ version }}",
      "instant": true
    }
  ],

  // options
  "options": {
    "textMode": "name",   // display text from label
    "colorMode": "none",  // disable color
    "reduceOptions": {
      "calcs": [
        "lastNotNull"
      ]
    }
  }
};
// }}}
// {{{ panel: Go version
local panelGoVersion = {
  // type, title and description
  "type": "stat",
  "title": "Go version",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "prometheus_build_info{job=\"${job}\"}",
      "legendFormat": "{{ goversion }}",
      "instant": true
    }
  ],

  // options
  "options": {
    "textMode": "name",   // display text from label
    "colorMode": "none",  // disable color
    "reduceOptions": {
      "calcs": [
        "lastNotNull"
      ]
    }
  }
};
// }}}
// {{{ panel: Kapitan Bomba
local kapitanBomba = grafana.text.new(
  transparent=true,
  mode='html',
  content='<img \nwidth=\"100%\"\nheight=\"100%\"\nsrc=\"https://public.amsdard.io/kapitan_bomba/003.jpg\">\n</img>',
);
// }}}
// {{{ panel: Uptime
local panelUptime = {
  // type, title and description
  "type": "stat",
  "title": "Uptime",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "time() - process_start_time_seconds{job=\"${job}\"}",
      "instant": true
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
    "colorMode": "none",  // disable color
    "reduceOptions": {
      "calcs": [
        "lastNotNull"
      ]
    }
  }
};
// }}}
// {{{ panel: Scrapes / minute
// grafonnet does not support time series panel yet :(
// hence raw json goes here
local panelScrapes = {
  // title and type
  "title": "Scrapes / minute",
  "type": "timeseries",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "rate(prometheus_target_interval_length_seconds_count{job=\"$job\"}[$__rate_interval]) * 60",
      "legendFormat": "scrapes/min",
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "#6262ce",
        "mode": "fixed"
      },
      "custom": {
        "fillOpacity": 6
      },
      "min": 0
    }
  },

  // options
  "options": {
    "legend": {
      "displayMode": "hidden"
    }
  }
};
// }}}
// {{{ panel: Time series
// grafonnet does not support time series panel yet :(
// hence raw json goes here
local panelTimeSeries = {
  // title and type
  "title": "Time series",
  "type": "timeseries",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "prometheus_tsdb_head_series{job=\"$job\"}",
      "legendFormat": "time series"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "#880749",
        "mode": "fixed"
      },
      "custom": {
        "fillOpacity": 6
      },
      "min": 0,
      "unit": "short"
    }
  },

  // options
  "options": {
    "legend": {
      "displayMode": "hidden"
    }
  }
};
// }}}
// {{{ panel: Samples appended
// grafonnet does not support time series panel yet :(
// hence raw json goes here
local panelSamples = {
  // title and type
  "title": "Samples appended / s",
  "type": "timeseries",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "rate(prometheus_tsdb_head_samples_appended_total{job=\"$job\"}[$__rate_interval])",
      "legendFormat": "appends/s"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "#880749",
        "mode": "fixed"
      },
      "custom": {
        "fillOpacity": 6
      },
      "min": 0,
      "unit": "short"
    }
  },

  // options
  "options": {
    "legend": {
      "displayMode": "hidden"
    }
  }
};
// }}}
// {{{ panel: Storage size
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
        "mode": "fixed",
        "fixedColor": "light-red"
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
// }}}
// {{{ panel: Jobs
local panelJobs = {
  // type, title and description
  "type": "stat",
  "title": "Jobs",
  "description": "Number of configured uniq jobs.",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "count(prometheus_sd_discovered_targets{job=\"$job\"})",
      "instant": true
    }
  ],

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
// }}}
// {{{ panel: Retention
local panelRetention = {
  // type, title and description
  "type": "stat",
  "title": "Retention",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "time() - prometheus_tsdb_lowest_timestamp_seconds{job=\"$job\"}",
      "instant": true
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
    "colorMode": "none",  // disable color
    "reduceOptions": {
      "calcs": [
        "lastNotNull"
      ]
    }
  }
};
// }}}
// {{{ panel: Targets
local panelTargets = {
  // type, title and description
  "type": "stat",
  "title": "Targets",
  "description": "In K8S this value is actually number of discovered targets, not scraped, so the value is bullshit.",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(prometheus_sd_discovered_targets{job=\"$job\"})",
      "instant": true
    }
  ],

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
// }}}
// }}}
// {{{ panels: TSDB
// {{{ panel: Storage size
// grafonnet does not support time series panel yet :(
// hence raw json goes here
local panelTSDBStorageSize = {
  // title and type
  "title": "Storage size",
  "type": "timeseries",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "prometheus_tsdb_storage_blocks_bytes{job=\"$job\"}",
      "legendFormat": "storage size",
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "light-red",
        "mode": "fixed"
      },
      "custom": {
        "fillOpacity": 6
      },
      "unit": "bytes"
    }
  },

  // options
  "options": {
    "legend": {
      "displayMode": "hidden"
    }
  }
};
// }}}
// {{{ panel: Samples appended / s
// grafonnet does not support time series panel yet :(
// hence raw json goes here
local panelTSDBSamplesAppended = {
  // title and type
  "title": "Samples appended / s",
  "type": "timeseries",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "rate(prometheus_tsdb_head_samples_appended_total{job=\"$job\"}[$__rate_interval])",
      "legendFormat": "appends/s",
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "super-light-red",
        "mode": "fixed"
      },
      "custom": {
        "fillOpacity": 6
      }
    }
  },

  // options
  "options": {
    "legend": {
      "displayMode": "hidden"
    }
  }
};
// }}}
// {{{ panel: Blocks loaded
// grafonnet does not support time series panel yet :(
// hence raw json goes here
local panelTSDBBlocksLoaded = {
  // title and type
  "title": "Blocks loaded",
  "type": "timeseries",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "prometheus_tsdb_blocks_loaded{job=\"$job\"}",
      "legendFormat": "blocks",
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "#e2c5c5",
        "mode": "fixed"
      },
      "custom": {
        "fillOpacity": 6
      }
    }
  },

  // options
  "options": {
    "legend": {
      "displayMode": "hidden"
    }
  }
};
// }}}
// {{{ panel: Series (head block)
// grafonnet does not support time series panel yet :(
// hence raw json goes here
local panelTSDBSeries = {
  // title and type
  "title": "Series (head block)",
  "type": "timeseries",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "increase(prometheus_tsdb_head_series_created_total{job=\"$job\"}[$__rate_interval])",
      "legendFormat": "series created"
    },
    {
      "expr": "increase(prometheus_tsdb_head_series_removed_total{job=\"$job\"}[$__rate_interval])",
      "legendFormat": "series removed"
    },
    {
      "expr": "prometheus_tsdb_head_series{job=\"$job\"}",
      "legendFormat": "series total"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "light-blue",
        "mode": "fixed"
      },
      "custom": {
        "fillOpacity": 20
      },
      "min": 0,
      "unit": "short"
    },
    "overrides": [
      {
        "matcher": {
          "id": "byName",
          "options": "series created"
        },
        "properties": [
          {
            "id": "custom.axisPlacement",
            "value": "right"
          },
          {
            "id": "color",
            "value": {
              "fixedColor": "dark-green",
              "mode": "fixed"
            }
          },
          {
            "id": "custom.drawStyle",
            "value": "bars"
          },
          {
            "id": "custom.lineWidth",
            "value": 2
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "series removed"
        },
        "properties": [
          {
            "id": "custom.axisPlacement",
            "value": "right"
          },
          {
            "id": "color",
            "value": {
              "fixedColor": "dark-red",
              "mode": "fixed"
            }
          },
          {
            "id": "custom.drawStyle",
            "value": "bars"
          },
          {
            "id": "custom.lineWidth",
            "value": 2
          }
        ]
      }
    ]
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panel: Chunks (head block)
// grafonnet does not support time series panel yet :(
// hence raw json goes here
local panelTSDBChunks = {
  // title and type
  "title": "Chunks (head block)",
  "type": "timeseries",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "increase(prometheus_tsdb_head_chunks_created_total{job=\"$job\"}[$__rate_interval])",
      "legendFormat": "chunks created"
    },
    {
      "expr": "increase(prometheus_tsdb_head_chunks_removed_total{job=\"$job\"}[$__rate_interval])",
      "legendFormat": "chunks removed"
    },
    {
      "expr": "prometheus_tsdb_head_chunks{job=\"$job\"}",
      "legendFormat": "chunks total"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "light-blue",
        "mode": "fixed"
      },
      "custom": {
        "fillOpacity": 20
      },
      "min": 0,
      "unit": "short"
    },
    "overrides": [
      {
        "matcher": {
          "id": "byName",
          "options": "chunks created"
        },
        "properties": [
          {
            "id": "custom.axisPlacement",
            "value": "right"
          },
          {
            "id": "color",
            "value": {
              "fixedColor": "dark-green",
              "mode": "fixed"
            }
          },
          {
            "id": "custom.drawStyle",
            "value": "bars"
          },
          {
            "id": "custom.lineWidth",
            "value": 2
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "chunks removed"
        },
        "properties": [
          {
            "id": "custom.axisPlacement",
            "value": "right"
          },
          {
            "id": "color",
            "value": {
              "fixedColor": "dark-red",
              "mode": "fixed"
            }
          },
          {
            "id": "custom.drawStyle",
            "value": "bars"
          },
          {
            "id": "custom.lineWidth",
            "value": 2
          }
        ]
      }
    ]
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panel: GC duration
// grafonnet does not support time series panel yet :(
// hence raw json goes here
local panelTSDBGCDuration = {
  // title and type
  "title": "GC duration (head block) (avg)",
  "type": "timeseries",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "rate(prometheus_tsdb_head_gc_duration_seconds_sum{job=\"$job\"}[$__rate_interval]) /\nrate(prometheus_tsdb_head_gc_duration_seconds_count{job=\"$job\"}[$__rate_interval])",
      "legendFormat": "gc duration"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "super-light-purple",
        "mode": "fixed"
      },
      "custom": {
        "lineWidth": 2,
        "drawStyle": "bars"
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
// }}}
// {{{ panel: Compaction duration
// grafonnet does not support time series panel yet :(
// hence raw json goes here
local panelTSDBCompactionDuration = {
  // title and type
  "title": "Compaction duration (avg)",
  "type": "timeseries",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "rate(prometheus_tsdb_compaction_duration_seconds_sum{job=\"$job\"}[$__rate_interval]) /\nrate(prometheus_tsdb_compaction_duration_seconds_count{job=\"$job\"}[$__rate_interval])",
      "legendFormat": "compaction duration"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "light-purple",
        "mode": "fixed"
      },
      "custom": {
        "lineWidth": 2,
        "drawStyle": "bars"
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
// }}}
// {{{ panel: WAL fsync duration
// grafonnet does not support time series panel yet :(
// hence raw json goes here
local panelTSDBWALFsyncDuration = {
  // title and type
  "title": "WAL fsync duration (avg)",
  "type": "timeseries",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "rate(prometheus_tsdb_wal_fsync_duration_seconds_sum{job=\"$job\"}[$__rate_interval]) /\nrate(prometheus_tsdb_wal_fsync_duration_seconds_count{job=\"$job\"}[$__rate_interval])",
      "legendFormat": "fsync duration",
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "light-purple",
        "mode": "fixed"
      },
      "custom": {
        "lineWidth": 2,
        "drawStyle": "bars"
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
// }}}
// }}}
// {{{ panels: Scraping
// {{{ panel: Scrapes / minute
// grafonnet does not support time series panel yet :(
// hence raw json goes here
local panelScrapingScrapes = {
  // title and type
  "title": "Scrapes / minute",
  "type": "timeseries",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "rate(prometheus_target_interval_length_seconds_count{job=\"$job\"}[$__rate_interval]) * 60",
      "legendFormat": "scrapes/min"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "#6262ce",
        "mode": "fixed"
      },
      "custom": {
        "fillOpacity": 6
      },
      "min": 0,
      "unit": "short"
    }
  },

  // options
  "options": {
    "legend": {
      "displayMode": "hidden"
    }
  }
};
/// }}}
// {{{ panel: Scrape intervals
// grafonnet does not support time series panel yet :(
// hence raw json goes here
local panelScrapingIntervals = {
  // title and type
  "title": "Scrape intervals",
  "type": "timeseries",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "prometheus_target_interval_length_seconds{job=\"$job\", quantile=\"0.9\"}",
      "legendFormat": "q0.9 ({{ interval }} int)"
    },
    {
      "expr": "prometheus_target_interval_length_seconds{job=\"$job\", quantile=\"0.99\"}",
      "legendFormat": "q0.99 ({{ interval }} int)"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "continuous-YlBl",
        "seriesBy": "last"
      },
      "custom": {
        "fillOpacity": 6
      },
      "decimals": 2,
      "unit": "s"
    }
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panel: Most samples top5
// grafonnet does not support time series panel yet :(
// hence raw json goes here
local panelScrapingMostSamplesTop5 = {
  // type, title and description
  "type": "table",
  "title": "Most samples top5",
  "description": "Which job produces the biggest number of samples.\n\nIf a job has multiple instances, only one is displayed, the one with biggest number (by using `max by (job)`.",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "topk(5,\n  max by (job) (scrape_samples_scraped)\n)",
      "format": "table",
      "instant": true,
    }
  ],

  // transformations
  "transformations": [
    {
      "id": "organize",
      "options": {
        "excludeByName": {
          "Time": true
        }
   //     "indexByName": {},
   //     "renameByName": {}
      }
    }
  ],

  // options
  "options": {
    "sortBy": [
      {
        "desc": true,
        "displayName": "Value"
      }
    ]
  },

  // filedConfig
  "fieldConfig": {
  }
};
// }}}
// {{{ panel: Longest scrapes top5
// grafonnet does not support time series panel yet :(
// hence raw json goes here
local panelScrapingLongestTop5 = {
  // type, title and description
  "type": "table",
  "title": "Longest scrapes top5",
  "description": "Which job took the longest.\n\nThe value is calculated as average of all the values from the last 1h (by using `avg_over_time[1h]`)\n\nIf a job has multiple instances, only one is displayed, the one with longest scrape (by using `max by (job)`.",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "topk(5,\n  max by (job) (avg_over_time(scrape_duration_seconds[1h]))\n)",
      "format": "table",
      "instant": true,
    }
  ],

  // transformations
  "transformations": [
    {
      "id": "organize",
      "options": {
        "excludeByName": {
          "Time": true
        },
        "renameByName": {
          "Value": "scrape duration"
        }
      }
    }
  ],

  // options
  "options": {
    "sortBy": [
      {
        "desc": true,
        "displayName": "scrape duration"
      }
    ]
  },

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "unit": "s"
    }
  }
};
// }}}
// {{{ panel: scraping text panel
// grafonnet does not support time series panel yet :(
// hence raw json goes here
local panelScrapingTextPanel = grafana.text.new(
  '', // name
  mode="markdown",
  content="# good to know\n- metric = a single \"word\" without any labels (dimension) attached to it\n- series = metric + uniq labels (hence, a single metric can have hundred of series)\n- sample = series + timestamp + value\n\n# handy queries\n- top 10 metrics with the biggest number of series\n    ```\n    topk(10, count by (__name__) ({__name__=~\".+\"}))\n    ```\n- top 10 jobs with the biggest number of series\n    ```\n    topk(10, sum by (job) (scrape_samples_scraped))\n    ```",
  transparent=true,
);
// }}}
// }}}
// {{{ panels: Query engine and HTTP
// {{{ panel: Engine query: queries / s
// grafonnet does not support time series panel yet :(
// hence raw json goes here
local panelQueryQueries = {
  // title and type
  "title": "Engine query: queries / s",
  "type": "timeseries",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "rate(prometheus_engine_query_duration_seconds_count{job=\"$job\"}[$__rate_interval])",
      "legendFormat": "{{ slice }}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 10
      }
    }
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panel: Engine query: queries duration
// grafonnet does not support time series panel yet :(
// hence raw json goes here
local panelQueryDuration = {
  // title and type
  "title": "Engine query: queries duration",
  "type": "timeseries",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "# avg = sum / count\n\nrate(prometheus_engine_query_duration_seconds_sum{job=\"$job\"}[$__rate_interval]) /\nrate(prometheus_engine_query_duration_seconds_count{job=\"$job\"}[$__rate_interval])",
      "legendFormat": "{{ slice }} (avg)"
    },
    {
      "expr": "prometheus_engine_query_duration_seconds{job=\"$job\", quantile=\"0.9\"}",
      "legendFormat": "{{ slice }} (q0.9)"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "unit": "s"
    }
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panel: Engine query: active queries
// grafonnet does not support time series panel yet :(
// hence raw json goes here
local panelQueryActive = {
  // title and type
  "type": "timeseries",
  "title": "Engine query: active queries",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "prometheus_engine_queries{job=\"$job\"}",
      "legendFormat": "active queries"
    },
    {
      "expr": "prometheus_engine_queries_concurrent_max{job=\"$job\"}",
      "legendFormat": "limit"
    }
  ],

  // filedConfig
  "fieldConfig": {

    "defaults": {
      "color": {
        "mode": "fixed"
      },
      "custom": {
        "fillOpacity": 12
      }
    },
    "overrides": [
      {
        "matcher": {
          "id": "byName",
          "options": "limit"
        },
        "properties": [
          {
            "id": "custom.fillOpacity",
            "value": 0
          },
          {
            "id": "color",
            "value": {
              "fixedColor": "light-red",
              "mode": "fixed"
            }
          }
        ]
      }
    ]
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panel: Http: requests / s
// grafonnet does not support time series panel yet :(
// hence raw json goes here
local panelQueryHttpRequests = {
  // type, title and description
  "type": "timeseries",
  "title": "Http: requests / s",
  "description": "Edit or explore this panel to see requests rate per handler.",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum (rate(prometheus_http_request_duration_seconds_count{job=\"$job\"}[$__rate_interval]))",
      "legendFormat": "total"
    },
    {
      "expr": "sum (rate(prometheus_http_request_duration_seconds_count{job=\"$job\", handler!=\"/metrics\"}[$__rate_interval]))",
      "legendFormat": "total (w/o /metrics)"
    },
    {
      "expr": "rate(prometheus_http_request_duration_seconds_count{job=\"$job\"}[$__rate_interval])",
      "legendFormat": "{{ handler }}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "continuous-BlYlRd"
      },
      "custom": {
        "fillOpacity": 6
      }
    }
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panel: Http: requests duration (avg) 
// grafonnet does not support time series panel yet :(
// hence raw json goes here
local panelQueryHttpDuration = {
  // title and type
  "type": "timeseries",
  "title": "Http: requests duration (avg)",
  "description": "Edit or explore this panel to see requests rate per handler.",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum (rate(prometheus_http_request_duration_seconds_sum{job=\"$job\"}[$__rate_interval])) /\nsum (rate(prometheus_http_request_duration_seconds_count{job=\"$job\"}[$__rate_interval]))",
      "legendFormat": "total"
    },
    {
      "expr": "sum (rate(prometheus_http_request_duration_seconds_sum{job=\"$job\", handler!=\"/metrics\"}[$__rate_interval])) /\nsum (rate(prometheus_http_request_duration_seconds_count{job=\"$job\", handler!=\"/metrics\"}[$__rate_interval]))",
      "legendFormat": "total (w/o /metrics)"
    },
    {
      "expr": "rate(prometheus_http_request_duration_seconds_sum{job=\"$job\"}[$__rate_interval]) /\nrate(prometheus_http_request_duration_seconds_count{job=\"$job\"}[$__rate_interval])",
      "legendFormat": "{{ handler }}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "continuous-YlRd"
      },
      "custom": {
        "fillOpacity": 6
      },
      "unit": "s"
    }
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panel: Http: response size (avg)
// grafonnet does not support time series panel yet :(
// hence raw json goes here
local panelQueryHttpResponseSize = {
  // title and type
  "type": "timeseries",
  "title": "Http: response size (avg)",
  "description": "Edit or explore this panel to see requests rate per handler.",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    
    {
      "expr": "sum(rate(prometheus_http_response_size_bytes_sum{job=\"$job\"}[$__rate_interval])) / \nsum(rate(prometheus_http_response_size_bytes_count{job=\"$job\"}[$__rate_interval]))",
      "legendFormat": "total"
    },
    {
      "expr": "sum(rate(prometheus_http_response_size_bytes_sum{job=\"$job\", handler!=\"/metrics\"}[$__rate_interval])) / \nsum(rate(prometheus_http_response_size_bytes_count{job=\"$job\", handler!=\"/metrics\"}[$__rate_interval]))",
      "legendFormat": "total (w/o /metrics)"
    },
    {
      "expr": "rate(prometheus_http_response_size_bytes_sum{job=\"$job\"}[$__rate_interval]) / \nrate(prometheus_http_response_size_bytes_count{job=\"$job\"}[$__rate_interval])",
      "legendFormat": "{{ handler }}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "continuous-GrYlRd"
      },
      "custom": {
        "fillOpacity": 6
      },
      "unit": "bytes"
    }
  },

  // options
  "options": {
  }
};
// }}}
// }}}
// {{{ panels: Errors
// {{{ panel: Http failed requests
// grafonnet does not support time series panel yet :(
// hence raw json goes here
local panelErrorsHttp = {
  // type, title and description
  "type": "timeseries",
  "title": "Http failed requests",
  "description": "Requests that returned 4** or 5**.",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(\n  increase(prometheus_http_requests_total{job=\"$job\", code!~\"2..|3..\"}[$__rate_interval])\n)",
      "legendFormat": "total"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "light-red",
        "mode": "fixed"
      },
      "custom": {
        "fillOpacity": 6,
        "lineWidth": 2,
        "drawStyle": "bars"
      }
    }
  },

  // options
  "options": {
    "legend": {
      "displayMode": "hidden"
    }
  }
};
// }}}
// {{{ panel: Dialer connection errors
// grafonnet does not support time series panel yet :(
// hence raw json goes here
local panelErrorsConnection = {
  // type, title and description
  "type": "timeseries",
  "title": "Dialer connection errors",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum by (dialer_name) (increase(net_conntrack_dialer_conn_failed_total{job=\"$job\"}[$__rate_interval]))",
      "legendFormat": "{{ dialer_name }}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "light-red",
        "mode": "fixed"
      },
      "custom": {
        "fillOpacity": 6,
        "lineWidth": 2,
        "drawStyle": "bars"
      }
    }
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panel: Scrape errors
// grafonnet does not support time series panel yet :(
// hence raw json goes here
local panelErrorsScrape = {
  // type, title and description
  "type": "timeseries",
  "title": "Scrape errors",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "increase(prometheus_target_scrapes_exceeded_body_size_limit_total{job=\"$job\"}[$__rate_interval])",
      "legendFormat": "exceeded_body_size_limit"
    },
    {
      "expr": "increase(prometheus_target_scrapes_exceeded_sample_limit_total{job=\"$job\"}[$__rate_interval])",
      "legendFormat": "exceeded_sample_limit"
    },
    {
      "expr": "increase(prometheus_target_scrapes_exemplar_out_of_order_total{job=\"$job\"}[$__rate_interval])",
      "legendFormat": "exemplar_out_of_order"
    },
    {
      "expr": "increase(prometheus_target_scrapes_sample_duplicate_timestamp_total{job=\"$job\"}[$__rate_interval])",
      "legendFormat": "sample_duplicate_timestamp"
    },
    {
      "expr": "increase(prometheus_target_scrapes_sample_out_of_bounds_total{job=\"$job\"}[$__rate_interval])",
      "legendFormat": "sample_out_of_bounds"
    },
    {
      "expr": "increase(prometheus_target_scrapes_sample_out_of_order_total{job=\"$job\"}[$__rate_interval])",
      "legendFormat": "sample_out_of_order"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "light-red",
        "mode": "fixed"
      },
      "custom": {
        "fillOpacity": 6,
        "lineWidth": 2,
        "drawStyle": "bars"
      }
    }
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panel: Scrape pools errors
// grafonnet does not support time series panel yet :(
// hence raw json goes here
local panelErrorsScrapePools = {
  // type, title and description
  "title": "Scrape pools errors",
  "type": "timeseries",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "increase(prometheus_target_scrape_pool_exceeded_label_limits_total{job=\"$job\"}[$__rate_interval])",
      "legendFormat": "exceeded_label_limits"
    },
    {
      "expr": "increase(prometheus_target_scrape_pool_exceeded_target_limit_total{job=\"$job\"}[$__rate_interval])",
      "legendFormat": "exceeded_target_limit"
    },
    {
      "expr": "increase(prometheus_target_scrape_pool_reloads_failed_total{job=\"$job\"}[$__rate_interval])",
      "legendFormat": "reloads_failed"
    },
    {
      "expr": "increase(prometheus_target_scrape_pools_failed_total{job=\"$job\"}[$__rate_interval])",
      "legendFormat": "creation_failed"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "light-red",
        "mode": "fixed"
      },
      "custom": {
        "fillOpacity": 6,
        "lineWidth": 2,
        "drawStyle": "bars"
      }
    }
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panel: Service discovery errors
// grafonnet does not support time series panel yet :(
// hence raw json goes here
local panelErrorsDiscovery = {
  // type, title and description
  "title": "Service discovery errors",
  "type": "timeseries",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "increase(prometheus_sd_dns_lookup_failures_total{job=\"$job\"}[$__rate_interval])",
      "legendFormat": "dns_lookup_failures"
    },
    {
      "expr": "sum(prometheus_sd_failed_configs{job=\"$job\"})",
      "legendFormat": "failed_configs"
    },
    {
      "expr": "increase(prometheus_sd_file_read_errors_total{job=\"$job\"}[$__rate_interval])",
      "legendFormat": "file_read_errors"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "light-red",
        "mode": "fixed"
      },
      "custom": {
        "fillOpacity": 6,
        "lineWidth": 2,
        "drawStyle": "bars"
      }
    }
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panel: TSDB errors
// grafonnet does not support time series panel yet :(
// hence raw json goes here
local panelErrorsTSDB = {
  // type, title and description
  "title": "TSDB errors",
  "type": "timeseries",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "increase(prometheus_tsdb_head_series_not_found_total{job=\"$job\"}[$__rate_interval])",
      "legendFormat": "series_not_found"
    },
    {
      "expr": "increase(prometheus_tsdb_out_of_bound_samples_total{job=\"$job\"}[$__rate_interval])",
      "legendFormat": "out_of_bound_samples"
    },
    {
      "expr": "increase(prometheus_tsdb_compactions_failed_total{job=\"$job\"}[$__rate_interval])",
      "legendFormat": "compactions_failed"
    },
    {
      "expr": "increase(prometheus_tsdb_head_truncations_failed_total{job=\"$job\"}[$__rate_interval])",
      "legendFormat": "head_truncations_failed"
    },
    {
      "expr": "increase(prometheus_tsdb_checkpoint_creations_failed_total{job=\"$job\"}[$__rate_interval])",
      "legendFormat": "checkpoint_creations_failed"
    },
    {
      "expr": "increase(prometheus_tsdb_checkpoint_deletions_failed_total{job=\"$job\"}[$__rate_interval])",
      "legendFormat": "checkpoint_deletions_failed"
    },
    {
      "expr": "increase(prometheus_tsdb_mmap_chunk_corruptions_total{job=\"$job\"}[$__rate_interval])",
      "legendFormat": "mmap_chunk_corruptions"
    },
    {
      "expr": "increase(prometheus_tsdb_reloads_failures_total{job=\"$job\"}[$__rate_interval])",
      "legendFormat": "reloads_failures"
    },
    {
      "expr": "increase(prometheus_tsdb_wal_corruptions_total{job=\"$job\"}[$__rate_interval])",
      "legendFormat": "wal_corruptions"
    },
    {
      "expr": "increase(prometheus_tsdb_wal_truncations_failed_total{job=\"$job\"}[$__rate_interval])",
      "legendFormat": "wal_truncations_failed"
    },
    {
      "expr": "increase(prometheus_tsdb_wal_writes_failed_total{job=\"$job\"}[$__rate_interval])",
      "legendFormat": "wal_writes_failed"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "light-red",
        "mode": "fixed"
      },
      "custom": {
        "fillOpacity": 6,
        "lineWidth": 2,
        "drawStyle": "bars"
      }
    }
  },

  // options
  "options": {
  }
};
// }}}
// }}}
// {{{ panels: Prometheus internals
// {{{ panel: CPU usage
// grafonnet does not support time series panel yet :(
// hence raw json goes here
local panelCPUUsage = {
  // type, title and description
  "title": "CPU usage",
  "type": "timeseries",

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
// }}}
// {{{ panel: Goroutines and threads
// grafonnet does not support time series panel yet :(
// hence raw json goes here
local panelGoroutines = {
  // type, title and description
  "type": "timeseries",
  "title": "Goroutines and threads",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "go_goroutines{job=\"$job\"}",
      "legendFormat": "goroutines"
    },
    {
      "expr": "go_threads{job=\"$job\"}",
      "legendFormat": "threads"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "continuous-BlPu"
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
  }
};
// }}}
// {{{ panel: Open files
// grafonnet does not support time series panel yet :(
// hence raw json goes here
local panelOpenFiles = {
  // type, title and description
  "title": "Open files",
  "type": "timeseries",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "process_open_fds{job=\"$job\"}",
      "legendFormat": "open files"
    },
    {
      "expr": "process_max_fds{job=\"$job\"}",
      "legendFormat": "limit"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "continuous-BlPu"
      },
      "unit": "short"
    },
    "overrides": [
      {
        "matcher": {
          "id": "byName",
          "options": "limit"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "semi-dark-red",
              "mode": "fixed"
            }
          }
        ]
      }
    ]
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panel: Memory usage
// grafonnet does not support time series panel yet :(
// hence raw json goes here
local panelMemoryUsage = {
  // type, title and description
  "type": "timeseries",
  "title": "Memory usage",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "process_resident_memory_bytes{job=\"$job\"}",
      "legendFormat": "resident memory"
    },
    {
      "expr": "process_virtual_memory_bytes{job=\"$job\"}",
      "hide": true,
      "legendFormat": "virtual memory"
    },
    {
      "expr": "rate(go_memstats_alloc_bytes_total{job=\"$job\"}[$__rate_interval])",
      "legendFormat": "allocations"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "#f43e58",
        "mode": "fixed"
      },
      "custom": {
        "fillOpacity": 6
      },
      "unit": "bytes"
    },
    "overrides": [
      {
        "matcher": {
          "id": "byName",
          "options": "allocations"
        },
        "properties": [
          {
            "id": "unit",
            "value": "binBps"
          },
          {
            "id": "color",
            "value": {
              "fixedColor": "#9f851f",
              "mode": "fixed"
            }
          }
        ]
      }
    ]
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panel: Heap
// grafonnet does not support time series panel yet :(
// hence raw json goes here
local panelHeap = {
  // type, title and description
  "type": "timeseries",
  "title": "Heap",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "go_memstats_heap_inuse_bytes{job=\"$job\"}",
      "legendFormat": "inuse"
    },
    {
      "expr": "go_memstats_heap_idle_bytes{job=\"$job\"}",
      "legendFormat": "idle"
    },
    {
      "expr": "go_memstats_heap_objects{job=\"$job\"}",
      "legendFormat": "objects"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "super-light-yellow",
        "mode": "fixed"
      },
      "custom": {
        "fillOpacity": 6
      },
      "unit": "bytes"
    },
    "overrides": [
      {
        "matcher": {
          "id": "byName",
          "options": "inuse"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "semi-dark-red",
              "mode": "fixed"
            }
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "objects"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "super-light-purple",
              "mode": "fixed"
            }
          },
          {
            "id": "unit",
            "value": "short"
          }
        ]
      }
    ]
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panel: Garbage collection
// grafonnet does not support time series panel yet :(
// hence raw json goes here
local panelGarbageCollection = {
  // type, title and description
  "title": "Garbage collection",
  "type": "timeseries",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "rate(go_gc_duration_seconds_count{job=\"$job\"}[$__rate_interval]) * 60",
      "legendFormat": "GCs / minute"
    },
    {
      "expr": "# avg = sum / caount\nrate(go_gc_duration_seconds_sum{job=\"$job\"}[$__rate_interval]) /\nrate(go_gc_duration_seconds_count{job=\"$job\"}[$__rate_interval])",
      "legendFormat": "GC time (avg)"
    },
    {
      "expr": "go_gc_duration_seconds{job=\"$job\", quantile=\"0.75\"}",
      "legendFormat": "GC time (q=0.75)"
    },
    {
      "expr": "go_gc_duration_seconds{job=\"$job\", quantile=\"1\"}",
      "legendFormat": "GC time (q=1)"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "dark-yellow",
        "mode": "fixed"
      },
      "custom": {
        "fillOpacity": 6
      },
      "unit": "s"
    },
    "overrides": [
      {
        "matcher": {
          "id": "byName",
          "options": "GC time (q=0.75)"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "light-yellow",
              "mode": "fixed"
            }
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "GC time (q=1)"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "super-light-yellow",
              "mode": "fixed"
            }
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "GCs / minute"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "dark-red",
              "mode": "fixed"
            }
          },
          {
            "id": "unit",
            "value": "none"
          }
        ]
      }
    ]
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panel: Self scraping: samples
// grafonnet does not support time series panel yet :(
// hence raw json goes here
local panelSelfScrapingSamples = {
  // type, title and description
  "title": "Self scraping: samples",
  "type": "timeseries",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "scrape_samples_scraped{job=\"$job\"}",
      "legendFormat": "samples scraped"
    },
    {
      "expr": "scrape_series_added{job=\"$job\"}",
      "legendFormat": "series added"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 6
      }
    },
    "overrides": [
      {
        "matcher": {
          "id": "byName",
          "options": "samples scraped"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "fixedColor": "semi-dark-blue",
              "mode": "fixed"
            }
          }
        ]
      }
    ]
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panel: Self scraping: duration
// grafonnet does not support time series panel yet :(
// hence raw json goes here
local panelSelfScrapingDuration = {
  // type, title and description
  "title": "Self scraping: duration",
  "type": "timeseries",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "scrape_duration_seconds{job=\"$job\"}",
      "legendFormat": "scrape duration"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "continuous-BlPu"
      },
      "custom": {
        "fillOpacity": 6
      },
      "unit": "s"
    }
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panel: Self scraping: http responses / minute
// grafonnet does not support time series panel yet :(
// hence raw json goes here
local panelSelfScrapingHTTP = {
  // type, title and description
  "title": "Self scraping: http responses / minute",
  "type": "timeseries",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "rate(promhttp_metric_handler_requests_total{job=\"$job\"}[$__rate_interval]) * 60",
      "legendFormat": "{{ code }}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "continuous-blues"
      },
      "custom": {
        "fillOpacity": 6
      }
    }
  },

  // options
  "options": {
  }
};
// }}}
// }}}
// {{{ panels: Prometheus logs
local panelLogs = {
  // type, title and description
  "type": "logs",
  "title": "",

  // datasource
  "datasource": {
    "type": "loki",
    "uid": "${LOKI_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "{app=\"${job}\"}"
    }
  ],

  // options
  "options": {
  }
};
// }}}
// }}}

dashboard
.addTemplate(varPrometheusDS)
.addTemplate(varLokiDS)
.addTemplate(varJob)

// {{{ top row
.addPanels(
  [
    panelVersion     { gridPos: {x: 0,  y: 0, w: 3, h: 5} },
    panelGoVersion   { gridPos: {x: 0,  y: 5, w: 3, h: 4} },
    kapitanBomba     { gridPos: {x: 3,  y: 0, w: 3, h: 5} },
    panelUptime      { gridPos: {x: 3,  y: 5, w: 3, h: 4} },

    panelScrapes     { gridPos: {x: 6,  y: 0, w: 6, h: 9} },
    panelTimeSeries  { gridPos: {x: 12, y: 0, w: 6, h: 5} },
    panelSamples     { gridPos: {x: 12, y: 5, w: 6, h: 4} },

    panelStorageSize { gridPos: {x: 18, y: 0, w: 3, h: 5} },
    panelJobs        { gridPos: {x: 18, y: 5, w: 3, h: 4} },
    panelRetention   { gridPos: {x: 21, y: 0, w: 3, h: 5} },
    panelTargets     { gridPos: {x: 21, y: 5, w: 3, h: 4} },
  ]
)
// }}}
// {{{ row: TSDB
.addPanel(
  grafana.row.new(title='TSDB', collapse=true)
  .addPanels(
    [
      panelTSDBStorageSize        { gridPos: {x: 0,  y: 10, w: 8, h: 8} },
      panelTSDBSamplesAppended    { gridPos: {x: 8,  y: 10, w: 8, h: 8} },
      panelTSDBBlocksLoaded       { gridPos: {x: 16, y: 10, w: 8, h: 8} },

      panelTSDBSeries             { gridPos: {x: 0,  y: 18, w: 12, h: 8} },
      panelTSDBChunks             { gridPos: {x: 12, y: 18, w: 12, h: 8} },

      panelTSDBGCDuration         { gridPos: {x: 0,  y: 26, w: 8, h: 8} },
      panelTSDBCompactionDuration { gridPos: {x: 8,  y: 26, w: 8, h: 8} },
      panelTSDBWALFsyncDuration   { gridPos: {x: 16, y: 26, w: 8, h: 8} },
    ]
  ),
  gridPos={X: 0, y: 9, w: 24, h: 1},
)
// }}}
// {{{ row: Scraping
.addPanel(
  grafana.row.new(title='Scraping', collapse=true)
  .addPanels(
    [
      panelScrapingScrapes         { gridPos: {x: 0,  y: 11, w: 12, h: 8} },
      panelScrapingIntervals       { gridPos: {x: 12, y: 11, w: 12, h: 8} },

      panelScrapingMostSamplesTop5 { gridPos: {x: 0,  y: 19, w: 6,  h: 8} },
      panelScrapingLongestTop5     { gridPos: {x: 6,  y: 19, w: 6,  h: 8} },
      panelScrapingTextPanel       { gridPos: {x: 12, y: 19, w: 12, h: 8} },
    ]
  ),
  gridPos={X: 0, y: 10, w: 24, h: 1},
)
// }}}
// {{{ row: Query engine and HTTP
.addPanel(
  grafana.row.new(title='Query engine and HTTP', collapse=true)
  .addPanels(
    [
      panelQueryQueries          { gridPos: {x: 0,  y: 12, w: 8, h: 8} },
      panelQueryDuration         { gridPos: {x: 8,  y: 12, w: 8, h: 8} },
      panelQueryActive           { gridPos: {x: 16, y: 12, w: 8, h: 8} },

      panelQueryHttpRequests     { gridPos: {x: 0,  y: 20, w: 8, h: 8} },
      panelQueryHttpDuration     { gridPos: {x: 8,  y: 20, w: 8, h: 8} },
      panelQueryHttpResponseSize { gridPos: {x: 16, y: 20, w: 8, h: 8} },
    ]
  ),
  gridPos={X: 0, y: 11, w: 24, h: 1},
)
// }}}
// {{{ row: Errors
.addPanel(
  grafana.row.new(title='Errors', collapse=true)
  .addPanels(
    [
      panelErrorsHttp        { gridPos: {x: 0,  y: 13, w: 8, h: 8} },
      panelErrorsConnection  { gridPos: {x: 8,  y: 13, w: 8, h: 8} },
      panelErrorsScrape      { gridPos: {x: 16, y: 13, w: 8, h: 8} },

      panelErrorsScrapePools { gridPos: {x: 0,  y: 21, w: 8, h: 8} },
      panelErrorsDiscovery   { gridPos: {x: 8,  y: 21, w: 8, h: 8} },
      panelErrorsTSDB        { gridPos: {x: 16, y: 21, w: 8, h: 8} },
    ]
  ),
  gridPos={X: 0, y: 12, w: 24, h: 1},
)
// }}}
// {{{ row: Prometheus internals (process and self scrape info)
.addPanel(
  grafana.row.new(title='Prometheus internals (process and self scrape info)', collapse=true)
  .addPanels(
    [
      panelCPUUsage             { gridPos: {x: 0,  y: 14, w: 12, h: 8} },
      panelGoroutines           { gridPos: {x: 12, y: 14, w: 6,  h: 8} },
      panelOpenFiles            { gridPos: {x: 18, y: 14, w: 6,  h: 8} },

      panelMemoryUsage          { gridPos: {x: 0,  y: 22, w: 12, h: 8} },
      panelHeap                 { gridPos: {x: 12, y: 22, w: 6,  h: 8} },
      panelGarbageCollection    { gridPos: {x: 18, y: 22, w: 6,  h: 8} },

      panelSelfScrapingSamples  { gridPos: {x: 0,  y: 30, w: 8,  h: 8} },
      panelSelfScrapingDuration { gridPos: {x: 8,  y: 30, w: 8,  h: 8} },
      panelSelfScrapingHTTP     { gridPos: {x: 16, y: 30, w: 8,  h: 8} },
    ]
  ),
  gridPos={X: 0, y: 13, w: 24, h: 1},
)
// }}}
// {{{ row: Prometheus logs
.addPanel(
  grafana.row.new(title='Prometheus logs', collapse=true)
    .addPanels(
      [
        panelLogs { gridPos: {x: 0,  y: 15, w: 24, h: 14} },
      ]
    ),
  gridPos={X: 0, y: 14, w: 24, h: 1},
)
// }}}
