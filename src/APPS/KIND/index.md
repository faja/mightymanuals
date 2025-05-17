---

- [official docs](https://kind.sigs.k8s.io/)
- [local install](../local_install.md)

---

# tldr;
```sh
kind get clusters                                     # list clusters
kind create cluster --name ${CLUSTER_NAME} --wait 5m  # create cluster
kind create cluster --name ${CLUSTER_NAME} --wait 5m --config config.yaml
kind delete cluster --name ${CLUSTER_NAME}            # delete cluster


# images
kind load docker-image my-custom-image-0 my-custom-image-1  # load docker image into kind node
docker exec kind-control-plane crictl images                # list images on a kind node
```
