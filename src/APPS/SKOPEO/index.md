---
- utility that performs various operations on container images and image repositories
- [github/skopeo](https://github.com/containers/skopeo)
---

- get sha of an image
    ```sh
    $ skopeo inspect docker://registry.fedoraproject.org/fedora:latest | jq '.Digest'
    "sha256:655721ff613ee766a4126cb5e0d5ae81598e1b0c3bcf7017c36c4d72cb092fe9"
    ```

- get a manifest (or a manifest list) of a tag:
    ```sh
    skopeo inspect --raw docker://registry/image:tag
    # this is actually equivalet of
    docker manifest inspect registry/iamge:tag
    ```

# a "SMALL" note on the image SHA
- image SHA or DIGEST, the one that we are using to pull the image,
  is actually a SHA/DIGEST of a manifest or manifest list
- manifest list allows you to pull an image for different ARCHITECTURE
  using the same SHA/DIGEST
- manifest list in turn contain other manifests with ARCHITECTURE
  specific SHA/DIGEST
- to visualize this:
    ```sh
    manifest list = ${TAG}@${SHA} : contains
      - manifest for AMD64 linux = ${TAG}@${SHA_AMD64_LINUX}
      - manifest for ARM64 linux = ${TAG}@${SHA_ARM64_LINUX}
      - manifest for ARM64 macos = ${TAG}@${SHA_ARM64_MAC}
    where ${SHA} != ${SHA_AMD64_LINUX} != ${SHA_ARM64_LINUX} != ${SHA_ARM64_MAC}
    ```