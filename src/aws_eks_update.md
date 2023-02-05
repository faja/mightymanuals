You should always always always refer to the official `AWS EKS UPGRADE` guide but that's basically the process
https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html

1. Update all "default" addons/plugins to recommended version:
- VPC CNI (aws-node): https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html
- kube-proxy: https://docs.aws.amazon.com/eks/latest/userguide/managing-kube-proxy.html
- coredns: https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html
- aws load balancer controller: https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html

2. Do whatever is needed as a prepreq

3. Update cluster

4. Update nodes

5. Once again update all addons/plugins to recommended version but this time, the new version of the cluster:)

## details
You should always always always refer to the official upgrade guid.
But more or less, to upgrade
- kube-proxy
    ```sh
    # fetch current Image
    kubectl describe daemonset kube-proxy -n kube-system | grep Image

    # set new version
    kubectl set image daemonset.apps/kube-proxy -n kube-system kube-proxy=${OUTPUT_FROM_THE_ABOVE_BUT_WITH_REPLACED_VERSION}
    ```
- coredns (same as for kube-proxy)
    ```sh
    # fetch current Image
    kubectl describe deployment coredns -n kube-system | grep Image

    # set new version
    kubectl set image deployment.apps/coredns -n kube-system  coredns=${OUTPUT_FROM_THE_ABOVE_BUT_WITH_REPLACED_VERSION}
- VPC CNI (aws-node)
    - it must be done ONE minor version at a time
    - download manifest, edit, apply
        ```sh
        VERSION=1.12.1
        curl -o aws-k8s-cni-${VERSION}.yaml https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/v${VERSION}/config/master/aws-k8s-cni.yaml
        # add `-eksbuild.1` the the end of the image name
        vim ${
        vim aws-k8s-cni-${VERSION}.yaml
        kubectl apply -f aws-k8s-cni-${VERSION}.yaml
        ```

---

# OTHER STUFF

## aws lb controller
```
kubectl create namespace mcplay
kubectl label  namespace mcplay elbv2.k8s.aws/pod-readiness-gate-inject=enabled
```

while true; do dig aws-load-balancer-webhook-service.kube-system.svc.cluster.local +short | grep -v -e '^$' > /dev/null && echo OK || echo FAILURE; sleep 1; done
