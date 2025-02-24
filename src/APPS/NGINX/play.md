---
pretty much the smallest nginx config for playing around

- `nginx.conf`:
```nginx
daemon            off;
user              nginx;
worker_processes  auto;
pid               /var/run/nginx.pid;

events {
  worker_connections  1024;
  multi_accept        on;
}

error_log /var/log/nginx/error.log notice;
  # note on docker this is symlinked to /dev/stderr

http {
  log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                  '$status $body_bytes_sent "$http_referer" '
                  '"$http_user_agent" "$http_x_forwarded_for"';

  access_log /var/log/nginx/access.log main;
    # note on docker this is symlinked to /dev/stdout

  # include /etc/nginx/mime.types;
  default_type text/plain;

  server_tokens off;

  server {
    listen       8081 ssl default_server;
    http2        on;
    server_name  _;

    ssl_certificate     /etc/nginx/ssl.pem;
    ssl_certificate_key /etc/nginx/ssl.pem;

    location / {
      return 200 "ok";
      #root   /usr/share/nginx/html;
      #index  index.html index.htm;
    }
  }
}
```

- `compose.yaml`
```yaml
---
name: nginx

services:
  nginx:
    container_name: nginx
    image: nginx:1.27.4
    restart: unless-stopped
    entrypoint:
      - nginx
    ports:
      - 8081:8081
    volumes:
      - /src/h02/nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - /src/ssl.pem:/etc/nginx/ssl.pem:ro
```
