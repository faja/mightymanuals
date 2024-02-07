
---

For now just a buch of quick copy paste snippets

## docker build and push

```
---
name: docker

on:
  push:
    branches:
      - master

jobs:
  docker_build:
    name: docker build
    runs-on: ubuntu-latest
    steps:

      - name: docker login
        uses: docker/login-action@v3
        with:
          registry: xyzzy.io
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: checkout
        uses: actions/checkout@v4

      - name: docker build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: xyzzy.io/foo/bar:latest
```
