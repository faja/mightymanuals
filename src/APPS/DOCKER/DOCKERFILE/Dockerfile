## base image
FROM python:3.9-alpine AS base
RUN apk add --no-cache \
  libyaml \
  openssl \
  && adduser -D monthy


## building tools to build all the dependencies
FROM base AS build-tools
RUN apk add \
  gcc \
  g++ \
  make \
  libyaml-dev \
  openssl-dev \
  && pip install -U pip \
  && pip install -U pip wheel setuptools


## app dependencies
FROM build-tools AS deps
COPY requirements.txt /tmp/
RUN pip install -r /tmp/requirements.txt \
  --prefix=/tmp/install


## building the app
FROM deps AS app
COPY app /tmp/
COPY setup.py /tmp/
RUN pip install /tmp/ --no-deps --prefix=/tmp/install


## finial image
FROM base
USER monty
COPY --form=app --chown root:root /tmp/install /usr/local
CMD ["superapp"]
