---

- template comments
```
{{/*   *}}    # without whitespace removal
{{- /* */}}   # with whitespace removal
```

- package and publish a chart
```sh
helm lint mychart/
helm package mychart/
helm push mychart-0.1.0.tgz oci://registry.example.com/helm-charts

helm show chart oci://registry.example.com/helm-charts/mychart --version 0.1.0
helm pull oci://registry.example.com/helm-charts/mychart --version 0.1.0
```

- helm-docs
```sh
helm-docs
```

- helm-docs `README.md.gotmpl`, simplest example
```
# mychart

{{ template "chart.valuesSection" . }}
```
see all available templates in the [official docs](https://github.com/norwoodj/helm-docs)
