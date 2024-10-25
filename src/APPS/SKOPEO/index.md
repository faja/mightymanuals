---
- utility that performs various operations on container images and image repositories
- [github/skopeo](https://github.com/containers/skopeo)
---

- get sha of an image ("top level" manifest sha)
    ```sh
    $ skopeo inspect docker://registry.fedoraproject.org/fedora:latest | jq '.Digest'
    "sha256:655721ff613ee766a4126cb5e0d5ae81598e1b0c3bcf7017c36c4d72cb092fe9"
    ```
    does not always work, if there is an arch/os missmatch :sadpepe:

- get a manifest (or a manifest list) of a tag:
    ```sh
    skopeo inspect --raw docker://registry/image:tag
    # this is actually equivalet of
    docker manifest inspect registry/iamge:tag
    ```
    however this does not print the "top level" manifest sha


  #### see [docker image sha madness](../DOCKER/SHA/index.md) for more details on sha stuff

---
