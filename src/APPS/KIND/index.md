---

- [official docs](https://kind.sigs.k8s.io/)

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

# ingress, aka how to access

## pod with port mapping
```yaml
kind: Pod
...
spec:
  containers:
    - name: ...
      ports:
        - containerPort: 5678
          hostPort: 80
```
then `docker container inspect kind-control-plane | grep IPAddress` and
`curl http://....` - should work

## service with NodePort

# confgi example
```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
- role: worker
networking:
  disableDefaultCNI: true
  podSubnet: 10.10.0.0/16
  serviceSubnet: 10.11.0.0/16
```
