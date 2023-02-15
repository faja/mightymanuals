# vim

## plugins
### fugitive
- how to add patch
    - open :G
    - `i` on a file
    - `s` to add only changes you want

# my awesome commit message for module versioning
```
eks-2.3.0 (app:X.X.X)

REQUIRED ACTION:
OPTIONAL ACTION:
CHANGES:
FEATURES:
FIXES:

REQUIRED ACTION: YES
* kinda, eks version was bumped to 1.24 (default,latest), if you relay
  on default vaule of `cluster_version` you have to set it to 1.21 to
  avoid cluster upgrade
OPTIONAL ACTION: NO


FEATURES:
* bumped default version of eks to 1.24 (latest)
* added ebs csi controll ami role
  (https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html)

FIXES:
* ...
* ...


```

# nginx
        ##
        location /api/data {
            proxy_set_header host $host;
            include /etc/nginx/backend_proxy.conf;
            proxy_http_version 1.1;
            rewrite ^/api/data$ / break;
            rewrite ^/api/data/(.*)$ /$1 break;
            proxy_pass $backend_schema://$backend_address:$backend_port;
            #proxy_pass https://myservice.mynamespace.svc.cluster.local:12500;
        }



---
prometheus query: 
`increase` use with `[$__rate_interval]
