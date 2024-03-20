---
- utility that performs various operations on container images and image repositories
- [github/skopeo](https://github.com/containers/skopeo)
---

- get sha of an image
    ```sh
    $ skopeo inspect docker://registry.fedoraproject.org/fedora:latest | jq '.Digest'
    "sha256:655721ff613ee766a4126cb5e0d5ae81598e1b0c3bcf7017c36c4d72cb092fe9"
    ```
