# 2.6.7 # 2023.01.11
FROM haproxy:2.6.7

USER root

RUN apt-get update  -y && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        dnsutils \
        netcat \
        curl \
        && \
    apt-get clean && \
    rm -rf /tmp/* /var/cache/* /var/lib/apt/lists/*

RUN mkdir /etc/haproxy && \
    chmod 700 /etc/haproxy && \
    chown haproxy:haproxy /etc/haproxy

COPY --chown=haproxy:haproxy haproxy.cfg dhparams.pem /etc/haproxy/
COPY --chown=haproxy:haproxy entrypoint.sh /entrypoint.sh

USER haproxy
WORKDIR /etc/haproxy

ENTRYPOINT ["/bin/bash"]
