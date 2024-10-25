---

# notes

- first of, when we are talking about pulling an image using **SHA**(DIGEST),
  we are talking about **MANIFEST** sha
- in general image information is built by:
    - [optional] manifest list ->
    - manifest ->
    - image(config) ->
    - layers
- note: ID of the container image (once we pulled it) is a different thing
- each of the above is called `mediaType` and has it's own **SHA**
- as mentioned, we have to use `manifest` or `manifest list` SHA to pull an image
- manifest list allows you to pull an image for different ARCHITECTURE/OS
  using the same SHA
- manifest list if it's there, it contains other manifests with ARCHITECTURE
  specific SHA/DIGEST
- to visualize this:
    ```sh
    manifest list = ${TAG}@${SHA} : contains
      - manifest for AMD64 linux = ${TAG}@${SHA_AMD64_LINUX}
      - manifest for ARM64 linux = ${TAG}@${SHA_ARM64_LINUX}
      - manifest for ARM64 macos = ${TAG}@${SHA_ARM64_MAC}
    where ${SHA} != ${SHA_AMD64_LINUX} != ${SHA_ARM64_LINUX} != ${SHA_ARM64_MAC}
    ```

# commands
- tldr; how to get "top level" sha (manifest or manifest list)
    - with NO pulling
        ```sh
        docker buildx imagetools inspect --format='{{json .Manifest.Digest}}' ${IMAGE} | jq . -r
        ```
    - after pulling
        ```sh
        docker image pull ${IMAGE}
        docker image inspect ${IMAGE} | jq '.[].RepoDigests'
        ```

- tldr; how to check if we do have manifest or manifest list
    ```sh
    docker manifest inspect ${IMAGE}
    ```

## single manifest
```sh
docker manifest inspect ${IMAGE}       # prints image SHA, NOT! manifest one
docker manifest inspect -v ${IMAGE}    # prints manifest SHA

skopeo inspect docker://${IMAGE}       # prints manifest SHA
skopeo inspect --raw docker://${IMAGE} # prints image SHA, NOT! manifest one

docker buildx imagetools inspect ${IMAGE} # prints manifest SHA
```
## manifest list
```sh
docker manifest inspect ${IMAGE}       # lists individual manifests SHA, NOT! top level SHA
docker manifest inspect -v ${IMAGE}    # lists individual manifests SHA, NOT! top level SHA

skopeo inspect docker://${IMAGE}       # does not work if there is missmatch of ARCH/OS
skopeo inspect --raw docker://${IMAGE} # lists individual manifests (with their SHAs), no top level SHA

docker buildx imagetools inspect ${IMAGE} # prints manifest list SHA
```
