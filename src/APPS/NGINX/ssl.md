---

```nginx
# minimal ssl config
http {
  server {
  }
}
```

```nginx
# mTLS
http {
  server {
    ...

    # mTLS - aka require client certificate
    ssl_client_certificate /etc/nginx/ca.crt;
    ssl_verify_client on;
    ssl_verify_depth 3; # this should be number of intermediate certs +1

    # couple of notes here:
    # - if client sends a pem bundle that is "cert + intermediate", the intermediate is
    #   treated as 'helpers' - equivalent of `-untrusted` option in openssl verify
    #   see `openssl` page in COMMANDS for more details
    # - usually we want a client to send a single cert only, and the ca.crt
    #   should contain intermediate and root
    #
    #
    ...
  }
}
```
