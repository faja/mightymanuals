FROM cgr.dev/chainguard/python:3.11 AS base

FROM cgr.dev/chainguard/python:3.11-dev AS build

# {{{ leveldb -----------------------------------------------------------------#
FROM build AS leveldb

USER root

RUN apk update && \
    apk add --no-cache --update-cache \
      cmake

USER nonroot

# https://github.com/google/leveldb.git
# 068d5ee1a3ac40dabd00d211d5013af44be55bea # main 2023.04.20
ARG LEVELDB_GIT_REPO=https://github.com/google/leveldb.git
ARG LEVELDB_GIT_COMMIT=068d5ee1a3ac40dabd00d211d5013af44be55bea
RUN cd /tmp && \
    git clone --recurse-submodules ${LEVELDB_GIT_REPO} && \
    cd leveldb && \
    git checkout ${LEVELDB_GIT_COMMIT}

RUN mkdir -p /tmp/leveldb/build && \
    cd /tmp/leveldb/build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    cmake --build . && \
    cmake --install . --prefix /tmp/install

# TODO:
RUN mv /tmp/install/lib64 /tmp/install/lib
# }}} -------------------------------------------------------------------------#

# {{{ deps --------------------------------------------------------------------#
FROM build AS deps

COPY --from=leveldb /tmp/install /usr
COPY requirements.txt /tmp/

RUN pip install --requirement /tmp/requirements.txt --prefix /tmp/install
# }}} -------------------------------------------------------------------------#

# {{{ electrumx ---------------------------------------------------------------#
FROM build AS electrumx

# https://github.com/spesmilo/electrumx
# 32a149500ebbfb67249c00160ad3f928627c2126 # master 2023.03.27
ARG GIT_REPO=https://github.com/spesmilo/electrumx
ARG GIT_COMMIT=32a149500ebbfb67249c00160ad3f928627c2126
RUN cd /tmp && \
    git clone ${GIT_REPO} && \
    cd ${GIT_REPO##https*/} && \
    git checkout ${GIT_COMMIT} && \
    pip install . --no-deps --prefix /tmp/install
# }}} -------------------------------------------------------------------------#

FROM base
COPY --from=leveldb   /tmp/install /usr
COPY --from=deps      /tmp/install /usr
COPY --from=electrumx /tmp/install /usr
