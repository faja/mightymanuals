- copy paste example
```
local panelLogs = {
  // type, title and description
  "type": "logs",
  "title": "",
  "description": "...",

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
    // these are all defaults:
    // "showTime": false,
    // "showLabels": false,
    // "showCommonLabels": false,
    // "wrapLogMessage": false,
    // "prettifyLogMessage": false,
    // "enableLogDetails": true,
    // "dedupStrategy": "none",
    // "sortOrder": "Descending"
  }
};
```
