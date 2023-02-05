local grafana = import 'grafonnet/grafana.libsonnet';

local dashboard = grafana.dashboard.new(
    'HAProxy',
    timezone='utc',
    time_from='now-3h',
    editable=true,
    graphTooltip=1,
);

// {{{ variables/templates
local varPrometheusDS = grafana.template.datasource(
  'PROMETHEUS_DS',     // name
  'prometheus',        // query
  'prometheus',        // current
  hide=true,           // ''      - disables hiding at all, everything is displayed
                       // 'label' - hide the name of the variable, and the drop down is displayed
                       // any other value - hides everything
  //regex='/prometheus/',
);

local varJob = grafana.template.custom(
    'job',             // name
    'haproxy', // query
    'haproxy', // current
    hide=true,
);

local varBackend = grafana.template.custom(
    'backend',   // name
    'backend1,backend2', // query
    'All', // query
    includeAll=true,
    hide=true,
);
// }}}

// {{{ panels
// {{{ panelHaproxyVersion
local panelHaproxyVersion = {
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
      "expr": "haproxy_process_build_info{job=\"${job}\"}",
      "instant": true,
      "legendFormat": "{{ version }}"
    }
  ],

  // transformations
  "transformations": [
    {
      "id": "merge",
      "options": {}
    },
    {
      "id": "renameByRegex",
      "options": {
        "regex": "([^-]+)-.+",
        "renamePattern": "$1"
      }
    }
  ],

  // filedConfig
  "fieldConfig": {
  },

  // options
  "options": {
    "textMode": "name",  // display text from label
    "colorMode": "none"  // disable color
  }
};
// }}}
// {{{ panelInstancesCount
local panelInstancesCount = {
  // type, title and description
  "type": "stat",
  "title": "HAProxy instances",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "count(haproxy_process_build_info{job=\"${job}\"})",
      "instant": true
    }
  ],

  // filedConfig
  "fieldConfig": {
  },

  // options
  "options": {
    "colorMode": "none" // disable color
  }
};
// }}}
// {{{ panelFrontendsCount
local panelFrontendsCount = {
  // type, title and description
  "type": "stat",
  "title": "Frontends",
  "description": "Does not include `healthz` and `stats` frontends",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "count(sum by (proxy) (haproxy_frontend_status{job=\"${job}\", proxy!=\"stats\", proxy!=\"healthz\"}))",
      "instant": true
    }
  ],

  // filedConfig
  "fieldConfig": {
  },

  // options
  "options": {
    "colorMode": "none" // disable color
  }
};
// }}}
// {{{ panelBackendsCount
local panelBackendsCount = {
  // type, title and description
  "type": "stat",
  "title": "Backends",
  "description": "Does not include `403` backend",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "count(sum by (proxy) (haproxy_backend_status{job=\"${job}\", proxy!=\"403\"}))",
      "instant": true
    }
  ],

  // filedConfig
  "fieldConfig": {
  },

  // options
  "options": {
    "colorMode": "none" // disable color
  }
};
// }}}
// {{{ panelActiveServersCount
local panelActiveServersCount = {
  // type, title and description
  "type": "stat",
  "title": "Active backend servers",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(avg by (proxy) (haproxy_backend_active_servers{job=\"${job}\"}))",
      "instant": true
    }
  ],

  // filedConfig
  "fieldConfig": {
  },

  // options
  "options": {
    "colorMode": "none" // disable color
  }
};
// }}}

// {{{ panelHaproxyUptime
local panelHaproxyUptime = {
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
      "expr": "time() - haproxy_process_start_time_seconds{job=\"${job}\"}",
      "instant": true,
      "legendFormat": "{{ instance }}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "fixed",
        "fixedColor": "#d5f6e5"
      },
      "unit": "s"
    }
  },

  // options
  "options": {
    "orientation": "vertical",
    "textMode": "value_and_name",
    "colorMode": "background"
  }
};
// }}}

// {{{ panelFrontendResponses
local panelFrontendResponses = {
  // type, title and description
  "type": "timeseries",
  "title": "Frontend responses/s",
  "description": "Does not include `healthz` and `stats` proxies",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum by (code) (rate(haproxy_frontend_http_responses_total{job=\"${job}\", proxy!=\"healthz\", proxy!=\"stats\"}[$__rate_interval]))",
      "legendFormat": "{{ code }}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 8,
      }
    },
    "overrides": [
      {
        "matcher": {
          "id": "byName",
          "options": "1xx"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "mode": "fixed",
              "fixedColor": "super-light-green"
            }
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "2xx"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "mode": "fixed",
              "fixedColor": "semi-dark-green"
            }
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "3xx"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "mode": "fixed",
              "fixedColor": "blue"
            }
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "4xx"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "mode": "fixed",
              "fixedColor": "orange"
            }
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "5xx"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "mode": "fixed",
              "fixedColor": "red"
            }
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "other"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "mode": "fixed",
              "fixedColor": "purple"
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
// {{{ panelFrontend4xxPercentage
local panelFrontend4xxPercentage = {
  // type, title and description
  "type": "timeseries",
  "title": "Frontend 4xx %",
  "description": "Percentage of 4xx responses (not including `healthz` and `stats` frontends)",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "100 *\nsum(rate(haproxy_frontend_http_responses_total{job=\"${job}\", proxy!=\"healthz\", proxy!=\"stats\", code=\"4xx\"}[$__rate_interval])) / \nsum(rate(haproxy_frontend_http_responses_total{job=\"${job}\", proxy!=\"healthz\", proxy!=\"stats\"}[$__rate_interval]))",
      "legendFormat": "4xx"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "fixed",
        "fixedColor": "super-light-red"
      },
      "custom": {
        "fillOpacity": 8,
        "thresholdsStyle": {
          "mode": "line"
        }
      },
      "thresholds": {
        "mode": "absolute",
        "steps": [
          {
            "color": "green",
            "value": null
          },
          {
            "color": "red",
            "value": 1
          }
        ]
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
// {{{ panelFrontend5xxPercentage
local panelFrontend5xxPercentage = {
  // type, title and description
  "type": "timeseries",
  "title": "Frontend 5xx %",
  "description": "Percentage of 5xx and other responses (not including `healthz` and `stats` frontends)",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "100 *\nsum(rate(haproxy_frontend_http_responses_total{job=\"${job}\", proxy!=\"healthz\", proxy!=\"stats\", code=~\"5xx|other\"}[$__rate_interval])) / \nsum(rate(haproxy_frontend_http_responses_total{job=\"${job}\", proxy!=\"healthz\", proxy!=\"stats\"}[$__rate_interval]))",
      "legendFormat": "5xx + other"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "fixed",
        "fixedColor": "super-light-red"
      },
      "custom": {
        "fillOpacity": 8,
        "thresholdsStyle": {
          "mode": "line"
        }
      },
      "thresholds": {
        "mode": "absolute",
        "steps": [
          {
            "color": "green",
            "value": null
          },
          {
            "color": "red",
            "value": 1
          }
        ]
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
// {{{ panelBackendAvgResponseTime
local panelBackendAvgResponseTime = {
  // type, title and description
  "type": "timeseries",
  "title": "Backend avg response time (by backend)",
  "description": "Per backend, avg over all instances",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "avg by (proxy) (haproxy_backend_response_time_average_seconds{job=\"${job}\", proxy!=\"403\"})",
      "legendFormat": "{{ proxy }}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 2
      },
      "unit": "s"
    }
  },

  // options
  "options": {
  }
};
// }}}

// {{{ panelPerBackendResponses
local panelPerBackendResponses = {
  // type, title and description
  "type": "timeseries",
  "title": "Backend responses/s",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum by (code) (rate(haproxy_backend_http_responses_total{job=\"${job}\", proxy=\"${backend}\"}[$__rate_interval]))",
      "legendFormat": "{{ code }}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 8,
      }
    },
    "overrides": [
      {
        "matcher": {
          "id": "byName",
          "options": "1xx"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "mode": "fixed",
              "fixedColor": "super-light-green"
            }
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "2xx"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "mode": "fixed",
              "fixedColor": "semi-dark-green"
            }
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "3xx"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "mode": "fixed",
              "fixedColor": "blue"
            }
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "4xx"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "mode": "fixed",
              "fixedColor": "orange"
            }
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "5xx"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "mode": "fixed",
              "fixedColor": "red"
            }
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "other"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "mode": "fixed",
              "fixedColor": "purple"
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
// {{{ panelPerBackend4xxPercentage
local panelPerBackend4xxPercentage = {
  // type, title and description
  "type": "timeseries",
  "title": "Backend 4xx %",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "100 *\nsum(rate(haproxy_backend_http_responses_total{job=\"${job}\", proxy=\"${backend}\", code=\"4xx\"}[$__rate_interval])) / \nsum(rate(haproxy_backend_http_responses_total{job=\"${job}\", proxy=\"${backend}\"}[$__rate_interval]))",
      "legendFormat": "4xx"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "fixed",
        "fixedColor": "super-light-red"
      },
      "custom": {
        "fillOpacity": 8,
        "thresholdsStyle": {
          "mode": "line"
        }
      },
      "thresholds": {
        "mode": "absolute",
        "steps": [
          {
            "color": "green",
            "value": null
          },
          {
            "color": "red",
            "value": 1
          }
        ]
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
// {{{ panelPerBackend5xxPercentage
local panelPerBackend5xxPercentage = {
  // type, title and description
  "type": "timeseries",
  "title": "Backend 5xx %",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "100 *\nsum(rate(haproxy_backend_http_responses_total{job=\"${job}\", proxy=\"${backend}\", code=~\"5xx|other\"}[$__rate_interval])) / \nsum(rate(haproxy_backend_http_responses_total{job=\"${job}\", proxy=\"${backend}\"}[$__rate_interval]))",
      "legendFormat": "Percentage of 5xx and other"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "fixed",
        "fixedColor": "super-light-red"
      },
      "custom": {
        "fillOpacity": 8,
        "thresholdsStyle": {
          "mode": "line"
        }
      },
      "thresholds": {
        "mode": "absolute",
        "steps": [
          {
            "color": "green",
            "value": null
          },
          {
            "color": "red",
            "value": 1
          }
        ]
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
// {{{ panelPerBackendAvgResponseTime
local panelPerBackendAvgResponseTime = {
  // type, title and description
  "type": "timeseries",
  "title": "Backend avg response time (by instance)",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "haproxy_backend_response_time_average_seconds{job=\"${job}\", proxy=\"${backend}\"}",
      "legendFormat": "{{ instance }}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 2
      },
      "unit": "s"
    }
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panelPerBackendBytes
local panelPerBackendBytes = {
  // type, title and description
  "type": "timeseries",
  "title": "Backend bytes in/out",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(rate(haproxy_backend_bytes_in_total{job=\"${job}\", proxy=\"${backend}\"}[$__rate_interval]))",
      "legendFormat": "in"
    },
    {
      "expr": "sum(rate(haproxy_backend_bytes_out_total{job=\"${job}\", proxy=\"${backend}\"}[$__rate_interval]))",
      "legendFormat": "out"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "fixed",
        "fixedColor": "semi-dark-blue"
      },
      "custom": {
        "fillOpacity": 8
      },
      "unit": "bytes"
    },
    "overrides": [
      {
        "matcher": {
          "id": "byName",
          "options": "out"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "mode": "fixed",
              "fixedColor": "semi-dark-purple"
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
// {{{ panelPerBackendConnectionRate
local panelPerBackendConnectionRate = {
  // type, title and description
  "type": "timeseries",
  "title": "Backend connections/s (by instance)",
  "description": "Connection rate from haproxy to backend servers. This is actually `rate(haproxy_backend_sessions_total)` which includes new connections + reused connections",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "rate(haproxy_backend_sessions_total{job=\"${job}\", proxy=\"${backend}\"}[$__rate_interval])",
      "legendFormat": "{{ instance }}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 2
      },
      "min": 0
    }
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panelPerBackendConnectionsCurrent
local panelPerBackendConnectionsCurrent = {
  // type, title and description
  "type": "timeseries",
  "title": "Backend connections (by instance)",
  "description": "Connections from haproxy to backend servers. This is actually based on `haproxy_backend_current_sessions` metric",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "haproxy_backend_current_sessions{job=\"${job}\", proxy=\"${backend}\"}",
      "legendFormat": "{{ instance }}"
    },
    {
      "expr": "min(haproxy_backend_limit_sessions{job=\"${job}\", proxy=\"${backend}\"})",
      "legendFormat": "max"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 2
      },
      "min": 0
    },
    "overrides": [
      {
        "matcher": {
          "id": "byName",
          "options": "max"
        },
        "properties": [
          {
            "id": "custom.lineWidth",
            "value": 2
          },
          {
            "id": "color",
            "value": {
              "mode": "fixed",
              "fixedColor": "red"
            }
          },
          {
            "id": "custom.fillOpacity",
            "value": 0
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
// {{{ panelPerBackendAvgConnectionTime
local panelPerBackendAvgConnectionTime = {
  // type, title and description
  "type": "timeseries",
  "title": "Backend avg connection time (by instance)",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "haproxy_backend_connect_time_average_seconds{job=\"${job}\", proxy=\"${backend}\"}",
      "legendFormat": "{{ instance }}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 2
      },
      "unit": "s"
    }
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panelPerBackendConnectionErrors
local panelPerBackendConnectionErrors = {
  // type, title and description
  "type": "timeseries",
  "title": "Backend connection errors (by instance)",
  "description": "Failed connections from haproxy to backend servers",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "rate(haproxy_backend_connection_errors_total{job=\"${job}\", proxy=\"${backend}\"}[$__rate_interval])",
      "legendFormat": "{{ instance }}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 2
      },
      "min": 0
    }
  },

  // options
  "options": {
  }
};
// }}}

// {{{ panelBackendResponses
local panelBackendResponses = {
  // type, title and description
  "type": "timeseries",
  "title": "Backend responses/s",
  "description": "Across all backends (does not include `403` backend)",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum by (code) (rate(haproxy_backend_http_responses_total{job=\"${job}\", proxy!=\"403\"}[$__rate_interval]))",
      "legendFormat": "{{ code }}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 8,
      }
    },
    "overrides": [
      {
        "matcher": {
          "id": "byName",
          "options": "1xx"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "mode": "fixed",
              "fixedColor": "super-light-green"
            }
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "2xx"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "mode": "fixed",
              "fixedColor": "semi-dark-green"
            }
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "3xx"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "mode": "fixed",
              "fixedColor": "blue"
            }
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "4xx"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "mode": "fixed",
              "fixedColor": "orange"
            }
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "5xx"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "mode": "fixed",
              "fixedColor": "red"
            }
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "other"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "mode": "fixed",
              "fixedColor": "purple"
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
// {{{ panelBackend4xxPercentage
local panelBackend4xxPercentage = {
  // type, title and description
  "type": "timeseries",
  "title": "Backend 4xx %",
  "description": "Across all backends (does not include `403` backend)",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "100 *\nsum(rate(haproxy_backend_http_responses_total{job=\"${job}\", proxy!=\"403\", code=\"4xx\"}[$__rate_interval])) / \nsum(rate(haproxy_backend_http_responses_total{job=\"${job}\", proxy!=\"403\"}[$__rate_interval]))",
      "legendFormat": "4xx"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "fixed",
        "fixedColor": "super-light-red"
      },
      "custom": {
        "fillOpacity": 8,
        "thresholdsStyle": {
          "mode": "line"
        }
      },
      "thresholds": {
        "mode": "absolute",
        "steps": [
          {
            "color": "green",
            "value": null
          },
          {
            "color": "red",
            "value": 1
          }
        ]
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
// {{{ panelBackend5xxPercentage
local panelBackend5xxPercentage = {
  // type, title and description
  "type": "timeseries",
  "title": "Backend 5xx %",
  "description": "Across all backends (does not include `403` backend)",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "100 *\nsum(rate(haproxy_backend_http_responses_total{job=\"${job}\", proxy!=\"403\", code=~\"5xx|other\"}[$__rate_interval])) / \nsum(rate(haproxy_backend_http_responses_total{job=\"${job}\", proxy!=\"403\"}[$__rate_interval]))",
      "legendFormat": "Percentage of 5xx and other"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "fixed",
        "fixedColor": "super-light-red"
      },
      "custom": {
        "fillOpacity": 8,
        "thresholdsStyle": {
          "mode": "line"
        }
      },
      "thresholds": {
        "mode": "absolute",
        "steps": [
          {
            "color": "green",
            "value": null
          },
          {
            "color": "red",
            "value": 1
          }
        ]
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

// {{{ panelFrontendConnectionRate
local panelFrontendConnectionRate = {
  // type, title and description
  "type": "timeseries",
  "title": "Connections/s (by instance)",
  "description": "Connections per second haproxy accepts across all frontends (DOES include `healthz` and `stats`). To get connection rate per frontend use `haproxy_frontend_connections_total{proxy=...}`",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "rate(haproxy_process_connections_total{job=\"${job}\"}[$__rate_interval])",
      "legendFormat": "{{ instance }}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 2
      }
    }
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panelFrontendConnectionsCurrent
local panelFrontendConnectionsCurrent = {
  // type, title and description
  "type": "timeseries",
  "title": "Connections (by instance)",
  "description": "Total number of current connections across all frontends (DOES include `healthz` and `stats`). To get current connections per frontend use `haproxy_frontend_current_sessions{proxy=...}`",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "haproxy_process_current_connections{job=\"${job}\"}",
      "legendFormat": "{{ instance }}"
    },
    {
      "expr": "min(haproxy_process_max_connections{job=\"${job}\"})",
      "legendFormat": "max"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 2
      },
      "min": 0
    },
    "overrides": [
      {
        "matcher": {
          "id": "byName",
          "options": "max"
        },
        "properties": [
          {
            "id": "custom.lineWidth",
            "value": 2
          },
          {
            "id": "color",
            "value": {
              "mode": "fixed",
              "fixedColor": "red"
            }
          },
          {
            "id": "custom.fillOpacity",
            "value": 0
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
// {{{ panelBackendConnectionRate
local panelBackendConnectionRate = {
  // type, title and description
  "type": "timeseries",
  "title": "Backend connections/s (by instance)",
  "description": "Connection rate from haproxy to backend servers. This is actually `rate(haproxy_backend_sessions_total)` which includes new connections + reused connections",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum by (instance) (rate(haproxy_backend_sessions_total{job=\"${job}\", proxy!=\"403\"}[$__rate_interval]))",
      "legendFormat": "{{ instance }}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 2
      },
      "min": 0
    }
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panelBackendConnectionsCurrent
local panelBackendConnectionsCurrent = {
  // type, title and description
  "type": "timeseries",
  "title": "Backend connections (by instance)",
  "description": "Connections from haproxy to backend servers. This is actually based on `haproxy_backend_current_sessions` metric",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum by (instance) (haproxy_backend_current_sessions{job=\"${job}\", proxy=\"403\"})",
      "legendFormat": "{{ instance }}"
    },
    {
      "expr": "min(haproxy_backend_limit_sessions{job=\"${job}\"})",
      "legendFormat": "max"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 2
      },
      "min": 0
    },
    "overrides": [
      {
        "matcher": {
          "id": "byName",
          "options": "max"
        },
        "properties": [
          {
            "id": "custom.lineWidth",
            "value": 2
          },
          {
            "id": "color",
            "value": {
              "mode": "fixed",
              "fixedColor": "red"
            }
          },
          {
            "id": "custom.fillOpacity",
            "value": 0
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
// {{{ panelBackendAvgConnectionTime
local panelBackendAvgConnectionTime = {
  // type, title and description
  "type": "timeseries",
  "title": "Backend avg connection time (by instance)",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "avg by (instance) (haproxy_backend_connect_time_average_seconds{job=\"${job}\", proxy!=\"403\"})",
      "legendFormat": "{{ instance }}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 2
      },
      "unit": "s"
    }
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panelBackendConnectionErrors
local panelBackendConnectionErrors = {
  // type, title and description
  "type": "timeseries",
  "title": "Backend connection errors (by instance)",
  "description": "Failed connections from haproxy to backend servers",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum by (instance) (rate(haproxy_backend_connection_errors_total{job=\"${job}\", proxy!=\"403\"}[$__rate_interval]))",
      "legendFormat": "{{ instance }}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 2
      },
      "min": 0
    }
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panelFrontendBytes
local panelFrontendBytes = {
  // type, title and description
  "type": "timeseries",
  "title": "Frontend bytes in/out",
  "description": "Does not include `healthz` and `stats` proxies",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(rate(haproxy_frontend_bytes_in_total{job=\"${job}\", proxy!=\"healthz\", proxy!=\"stats\"}[$__rate_interval]))",
      "legendFormat": "in"
    },
    {
      "expr": "sum(rate(haproxy_frontend_bytes_out_total{job=\"${job}\", proxy!=\"healthz\", proxy!=\"stats\"}[$__rate_interval]))",
      "legendFormat": "out"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "fixed",
        "fixedColor": "semi-dark-blue"
      },
      "custom": {
        "fillOpacity": 8
      },
      "unit": "bytes"
    },
    "overrides": [
      {
        "matcher": {
          "id": "byName",
          "options": "out"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "mode": "fixed",
              "fixedColor": "semi-dark-purple"
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
// {{{ panelBackendBytes
local panelBackendBytes = {
  // type, title and description
  "type": "timeseries",
  "title": "Backend bytes in/out",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(rate(haproxy_backend_bytes_in_total{job=\"${job}\", proxy!=\"403\"}[$__rate_interval]))",
      "legendFormat": "in"
    },
    {
      "expr": "sum(rate(haproxy_backend_bytes_out_total{job=\"${job}\", proxy!=\"403\"}[$__rate_interval]))",
      "legendFormat": "out"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "fixed",
        "fixedColor": "semi-dark-blue"
      },
      "custom": {
        "fillOpacity": 8
      },
      "unit": "bytes"
    },
    "overrides": [
      {
        "matcher": {
          "id": "byName",
          "options": "out"
        },
        "properties": [
          {
            "id": "color",
            "value": {
              "mode": "fixed",
              "fixedColor": "semi-dark-purple"
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
// {{{ panelProcessBusy
local panelProcessBusy = {
  // type, title and description
  "type": "timeseries",
  "title": "Busy % (by instance)",
  "description": "Percentage of last second spent doing some work",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "100 - haproxy_process_idle_time_percent{job=\"${job}\"}",
      "legendFormat": "{{ instance }}"
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "palette-classic"
      },
      "custom": {
        "fillOpacity": 2
      },
      "min": 0
    }
  },

  // options
  "options": {
  }
};
// }}}
// {{{ panelProcessFailedResolutions
local panelProcessFailedResolutions = {
  // type, title and description
  "type": "timeseries",
  "title": "Failed DNS resolutions",
  "description": "Total number of failed DNS resolutions",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "sum(increase(haproxy_process_failed_resolutions{job=\"${job}\"}[1h]))"
    }
  ],

  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "fixed",
        "fixedColor": "red"
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
// }}}

dashboard
.addTemplate(varPrometheusDS)
.addTemplate(varJob)
.addTemplate(varBackend)

.addPanels(
  [
    panelHaproxyVersion     { gridPos: {x: 0,  y: 0, w: 6,  h: 2} },
    panelInstancesCount     { gridPos: {x: 6,  y: 0, w: 6,  h: 2} },
    panelFrontendsCount     { gridPos: {x: 12, y: 0, w: 4,  h: 2} },
    panelBackendsCount      { gridPos: {x: 16, y: 0, w: 4,  h: 2} },
    panelActiveServersCount { gridPos: {x: 20, y: 0, w: 4,  h: 2} },

    panelHaproxyUptime { gridPos: {x: 0, y: 2, w: 24, h: 2} },

    panelFrontendResponses     { gridPos: {x: 0,  y: 4, w: 12, h: 8} },
    panelFrontend4xxPercentage { gridPos: {x: 12, y: 4, w: 6,  h: 8} },
    panelFrontend5xxPercentage { gridPos: {x: 18, y: 4, w: 6,  h: 8} },

    panelBackendAvgResponseTime { gridPos: {x: 0, y: 12, w: 24, h: 8} },
  ]
)

.addPanel(
  grafana.row.new(title='Backend: ${backend}', repeat='backend', collapse=true)
  .addPanels(
    [
      panelPerBackendResponses     { gridPos: {x: 0,  y: 21, w: 12, h: 8} },
      panelPerBackend4xxPercentage { gridPos: {x: 12, y: 21, w: 6,  h: 8} },
      panelPerBackend5xxPercentage { gridPos: {x: 18, y: 21, w: 6,  h: 8} },

      panelPerBackendAvgResponseTime { gridPos: {x: 0,  y: 29, w: 12, h: 8} },
      panelPerBackendBytes           { gridPos: {x: 12, y: 29, w: 12, h: 8} },

      panelPerBackendConnectionRate     { gridPos: {x: 0,  y: 37, w: 12, h: 8} },
      panelPerBackendConnectionsCurrent { gridPos: {x: 12, y: 37, w: 12, h: 8} },

      panelPerBackendAvgConnectionTime { gridPos: {x: 0,  y: 45, w: 12, h: 8} },
      panelPerBackendConnectionErrors  { gridPos: {x: 12, y: 45, w: 12, h: 8} },
    ]
  ),
  gridPos={x: 0, y: 20, w: 24, h: 1},
)

.addPanel(
  grafana.row.new(title='More stuff', collapse=true)
  .addPanels(
    [
      panelBackendResponses     { gridPos: {x: 0,  y: 22, w: 12, h: 8} },
      panelBackend4xxPercentage { gridPos: {x: 12, y: 22, w: 6,  h: 8} },
      panelBackend5xxPercentage { gridPos: {x: 18, y: 22, w: 6,  h: 8} },

      panelFrontendConnectionRate     { gridPos: {x: 0,  y: 30, w: 12, h: 8} },
      panelFrontendConnectionsCurrent { gridPos: {x: 12, y: 30, w: 12, h: 8} },

      panelBackendConnectionRate     { gridPos: {x: 0,  y: 38, w: 12, h: 8} },
      panelBackendConnectionsCurrent { gridPos: {x: 12, y: 38, w: 12, h: 8} },
      panelBackendAvgConnectionTime  { gridPos: {x: 0,  y: 46, w: 12, h: 8} },
      panelBackendConnectionErrors   { gridPos: {x: 12, y: 46, w: 12, h: 8} },

      panelFrontendBytes { gridPos: {x: 0,  y: 54, w: 12, h: 8} },
      panelBackendBytes  { gridPos: {x: 12, y: 54, w: 12, h: 8} },

      panelProcessBusy              { gridPos: {x: 0,  y: 62, w: 12, h: 8} },
      panelProcessFailedResolutions { gridPos: {x: 12, y: 62, w: 12, h: 8} },
    ]
  ),
  gridPos={x: 0, y: 21, w: 24, h: 1},
)
