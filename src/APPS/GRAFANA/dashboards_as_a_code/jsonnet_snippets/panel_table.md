- top 5 recently started jobs
```
// HOWTO
// the way to achieve this is
//   - use instant query
//   - use transformations, reduce, that will convert series to rows
//   - it will be automatically sorted

local panelJobsTop5Created = {
  // type, title and description
  "type": "table",
  "title": "Jobs recently created (TOP5)",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "bottomk(5, time() - kube_job_created{namespace=~\"$namespace\"})",
      "legendFormat": "{{ job_name }} (ns: {{ namespace }})",
      "instant": true

    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "unit": "s"
    },
  },

  // options
  "options": {
    "showHeader": false
  },

  // transformations
  "transformations": [
    {
      "id": "reduce"
    }
  ]
};
```

- color and filter columns for instance, just a single label
```
local panelJobsFailedJobs = {
  // type, title and description
  "type": "table",
  "title": "Failed jobs",

  // datasource
  "datasource": {
    "type": "prometheus",
    "uid": "${PROMETHEUS_DS}"
  },

  // targets
  "targets": [
    {
      "expr": "kube_job_status_failed{namespace=~\"$namespace\"}==1",
      "legendFormat": "{{ job_name }} (ns: {{ namespace }})",
      "instant": true
    }
  ],

  // filedConfig
  "fieldConfig": {
    "defaults": {
      "color": {
        "fixedColor": "red",
        "mode": "fixed"
      },
      "custom": {
        "displayMode": "color-text"
      }
    }
  },

  // options
  "options": {
    "showHeader": false,
  },

  // transformations
  "transformations": [
    {
      "id": "reduce"
    },
    {
      "id": "filterFieldsByName",
      "options": {
        "include": {
          "names": [
            "Field"
          ]
        }
      }
    }
  ]
};
```

- copy paste example
```
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
```
