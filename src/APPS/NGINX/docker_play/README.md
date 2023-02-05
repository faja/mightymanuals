```sh
IMAGE_NAME=nginx
IMAGE_TAG=1.22.1

docker pull ${IMAGE_NAME}:${IMAGE_TAG}
docker run --rm --name nginx -it --entrypoint bash -p 8080:8080 -v $(pwd)/nginx:/etc/nginx ${IMAGE_NAME}:${IMAGE_TAG}
```
