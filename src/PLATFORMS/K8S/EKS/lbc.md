# AWS Load Balancer Controller aka LBC

- [official docs](https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/)
- [github](https://github.com/kubernetes-sigs/aws-load-balancer-controller)
- [releses](https://github.com/kubernetes-sigs/aws-load-balancer-controller/releases)

Everything you need to know about AWS Load Balancer Controller and creating ingresses. In this doc I'm gonna cover:
- how to install LBC
- `Ingress` resource examples
- zero-downtime deployments, readiness-gate, draining and timeouts

# INSTALL

## pre reqs
- **vpc subnets should be tagged**, there are other "more sophisticated" aproaches,
  but in general tag private subnets with:
  ```
  kubernetes.io/role/internal-elb = 1
  ```
  and public ones with:
  ```
  kubernetes.io/role/elb = 1
  ```
  for more details please refer to [subnet discovery](https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/deploy/subnet_discovery/)

- **iam role and policy** - lbc needs a dedicated role and policy - this should be covered
  by `eks` tf module - the role needs to be passed to helm chart, but just for reference:
  ```sh
  VERSION=3.6.3 # 2026.11.14
  curl -o iam_lbc.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v${VERSION}/docs/install/iam_policy.json
  ```

## helm
I usually mirror the chart, I pull the git repo and copy the chart to my "`k8s/charts`"
```
3.6.3 (2026.11.14) (e8491dea5e67f678c13347d1a2b46a5afc6dc538)
https://github.com/kubernetes-sigs/aws-load-balancer-controller/blob/main/helm/aws-load-balancer-controller/Chart.yaml
git pull
```
Note that chart not always follows the latest version of the "app" itself, so better check for the latest version
and compare with the one specified in the chart -> [releses](https://github.com/kubernetes-sigs/aws-load-balancer-controller/releases)

Alos, note the chart comes with CRDs, these should be managed by hand - helm doesn't upgrade CRDs with `helm upgrade`.
My usual solution is to managed CRDs as a dedicated chart `aws-load-balancer-controller-CRDS`

And here is the Custom values:
```yaml
---
clusterName: prd
defaultTargetType: ip

region: eu-west-1
vpcId: vpc-abcdefghijklmnopr

serviceAccount:
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::123456789000:role/XyzzyEKSClusterPrdLoadBalancerController

# the above :pointup, is "good enough"
# and below is some extra readiness-gate related "good to have" stuff

# NOTE: TODO: add info about readiness gate
# namespace labeling: kubectl label namespace <ns> elbv2.k8s.aws/pod-readiness-gate-inject=enabled
podMutatorWebhookConfig:
  failurePolicy: Fail # pods not gonna be created if webhook is not available (or if something is wrong with it)
objectSelector:
  matchLabels:
    elbv2.k8s.aws/pod-readiness-gate-inject: enabled # only apply to pods with this label

# NOTE: use
# containers:
# - lifecycle:
#     prestop:
#       sleep: {seconds: 20}
```

```sh
# intall CRDS
helm upgrade -n kube-system --skip-crds --atomic --install aws-load-balancer-controller-CRDS aws-load-balancer-controller-CRDS
# install
helm upgrade -n kube-system --skip-crds --atomic --install aws-load-balancer-controller aws-load-balancer-controller --values values.yaml
```

# `Ingress` resources

## super simple, only for testing
```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata: { name: echo }
spec:
  replicas: 2
  selector: { matchLabels: { app: echo } }
  template:
    metadata: { labels: { app: echo } }
    spec:
      containers:
        - name: echo
          image: registry.k8s.io/e2e-test-images/agnhost:2.53
          args: ["netexec", "--http-port=8080"]
          ports: [{ containerPort: 8080 }]

---
apiVersion: v1
kind: Service
metadata: { name: echo }
spec:
  selector: { app: echo }
  ports: [{ port: 80, targetPort: 8080 }]

---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: echo
  annotations:
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/scheme: internal
spec:
  ingressClassName: alb
  rules:
    - http:
        paths:
          - { path: /, pathType: Prefix, backend: { service: { name: echo, port: { number: 80 } } } }
```

## all the goodies
- [docs for annotations](https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/guide/ingress/annotations/)

```yaml
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: echo
  annotations:
    # these are alb specific
    alb.ingress.kubernetes.io/group.name: ...    # ok, this is the way to create 1 ALB for multiple Ingress resources
    alb.ingress.kubernetes.io/scheme: ...        # `internet-facing`, `internal`
    alb.ingress.kubernetes.io/target-type: ...   # `ip` or `instance`

    alb.ingress.kubernetes.io/inbound-cidrs: {{ .Values.ingress.inboundCidrs }}
    alb.ingress.kubernetes.io/certificate-arn: {{ .Values.ingress.certArn }}
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS":443}]'
    alb.ingress.kubernetes.io/actions.ssl-redirect: '{"Type": "redirect", "RedirectConfig": { "Protocol": "HTTPS", "Port": "443", "StatusCode": "HTTP_301"}}'

    # this is target specifc
    alb.ingress.kubernetes.io/healthcheck-path: {{ .Values.ingress.healthcheckPath }}
spec:
  ingressClassName: alb
  rules:
    {{- range $host := .Values.ingress.externalURLs }}
    - host: {{ $host }}
      http:
        paths:
          {{- if and (eq $.Values.ingress.class "alb") $.Values.ingress.ssl $.Values.ingress.httpsAutoRedirect }}
          - path: /
            pathType: Prefix
            backend:
              service:
                name: ssl-redirect
                port:
                  name: use-annotation
          {{- end }}
          - path: /
            pathType: Prefix
            backend:
              service:
                name: {{ $.Chart.Name }}
                port:
                  number: 80
    {{- end }}
{{- end }}
```

### real life example
My approach is the following, when I do have a single ALB that's gonna manage
multiple apps etc, I create the ALB first, configure cert, http->https redirect,
All the ALB specific annotathin goes here.
Then, app/target specific `Ingress` resources are simple and have just a few annotations.

```yaml
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: base
  annotations:
    alb.ingress.kubernetes.io/group.name: prd
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/inbound-cidrs: "0.0.0.0/0"
    alb.ingress.kubernetes.io/certificate-arn: arn....
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS":443}]'
    alb.ingress.kubernetes.io/actions.ssl-redirect: '{"Type": "redirect", "RedirectConfig": { "Protocol": "HTTPS", "Port": "443", "StatusCode": "HTTP_301"}}'
spec:
  ingressClassName: alb
  rules:
    - host: hub.xyzzy.com # check if we can go withouth `host`
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: ssl-redirect
                port:
                  name: use-annotation
```

```yaml
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: base
  annotations:
    alb.ingress.kubernetes.io/group.name: prd # use the same group
    alb.ingress.kubernetes.io/healthcheck-path: /healthz
spec:
  ingressClassName: alb
  rules:
    - host: hub.xyzzy.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: hub
                port:
                  number: 80
```

# zero-downtime deployments, readiness-gate, draining and timeouts
TODO
