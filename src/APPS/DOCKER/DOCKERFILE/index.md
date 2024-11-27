# copy paste examples

- [alpine](./ALPINE/index.md)
- [debian](./DEBIAN/index.md)
- [wolfi](./WOLFI/index.md)
- [python](./PYTHON/index.md)

---

### some general rules how to build images
- remember about caching
    - order layers correctly
    - combine multiple RUN command with `&&`
- no extra tooling
    - avoid installing unnecessary tools
    - use "no-cache" flags like
- single container == single service
    - eg: do not install cron, redis and supervisor next to your app in a single container
- use language base images (not distro)
- use small base images
    - `-slim` versions, or
    - `-alpine` ideally
    - `scratch` for compiled languages: go, rust
- use `.dockerignore`!!!
    - remember, during the build the whole context (`.`) is being copied!
    - think about `node_modules` etc...
- use mutli-stage builds

### multistage build example

```yaml
{{#include Dockerfile}}
```
