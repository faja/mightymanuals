- datasource `prometheus`
```
local varPrometheusDS = grafana.template.datasource(
  'PROMETHEUS_DS',     // name
  'prometheus',        // query
  'prometheus',        // current
  hide=true,           // ''      - disables hiding at all, everything is displayed
                       // 'label' - hide the name of the variable, and the drop down is displayed
                       // any other value - hides everything
  //regex='/prometheus/',
);

dashboard
.addTemplate(varPrometheusDS)
```

- datasource `loki`
```
local varLokiDS = grafana.template.datasource(
    'LOKI_DS',           // name
    'loki',              // query
    'loki',              // current
    hide=true,           // ''      - disables hiding at all, everything is displayed
                         // 'label' - hide the name of the variable, and the drop down is displayed
                         // any other value - hides everything
    //regex='/loki/',
);

dashboard
.addTemplate(varLokiDS)
```

- constant or custom text, eg: job name
```
local varJob = grafana.template.custom(
  'job',            // name
  'prometheus',     // query
  'prometheus',     // current
  hide=true,        // default = ''
  multi=true,       // default = false
  includeAll=true,  // default = false
);

dashboard
.addTemplate(varJob)
```

- prometheus label_values
```
local varCluster = std.mergePatch(
  grafana.template.new(
    'cluster',                                         // name
    {"type": "prometheus", "uid": "${PROMETHEUS_DS}"}, // datasource
    "label_values(rabbitmq_version_info, cluster)",    // query
    current="clusterXYZ",                              // optional, if we wanna set "default" selection
  ),
  {
    "definition": "label_values(rabbitmq_version_info, cluster)"  // optional
  }
);


dashboard
.addTemplate(varCluster)
```

- text field variable (with optional default
```
local varPod = std.mergePatch(
  grafana.template.text(
    'pod', // name
  ),
  {
    "current": {
      "value": "_name_of_the_pod_" // default
    }
  }
);
```
