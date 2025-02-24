---
pretty much the smallest haproxy config

- `haproxy.cfg`:
```yaml
global
    log stdout daemon
    stats socket /tmp/haproxy.stats mode 600 user haproxy group haproxy level operator

defaults
    log global
    option httplog

frontend http
    bind *:8080 ssl crt /etc/haproxy/ssl.pem alpn h2
    mode http
    http-request return status 200 content-type "text/plain" string "lesssgo"
```

- `compose.yaml`
```yaml
---
name: haproxy

services:
  haproxy:
    container_name: haproxy
    image: haproxy:3.0.8
    restart: unless-stopped
    entrypoint:
      - haproxy
    command:
      - -W
      - -f
      - /etc/haproxy/haproxy.cfg
    ports:
      - 8080:8080
    volumes:
      - /src/h01/haproxy/haproxy.cfg:/etc/haproxy/haproxy.cfg:ro
      - /src/ssl.pem:/etc/haproxy/ssl.pem:ro
```
