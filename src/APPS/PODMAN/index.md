### `podman image`
```sh
podman image diff ${IMAGE_OLD} ${IMAGE_NEW}
podman image tree ${IMAGE}
podman image inspect ${IMAGE}
podman image inspect --format '{{ .Config.StopSignal }}' ${IMAGE}
```
