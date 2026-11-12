# TODO

My approach to hosting/mirroring helm charts:

> `k8s/charts` - contains charts, but these are symlinks to `k8s/charts/_mirror/${CHART_NAME}/${CHART_NAME}:${VERSION}`

```sh
mkdir -p k8s/charts/_mirror/cilium
cd k8s/charts/_mirror/cilium
helm pull --untar oci://quay.io/cilium/charts/cilium:1.20.4@sha256:712e1f65bf30533d117d1996ac3ace3efdb2521302d31ee887b1e45806bd6b64
rm -rf cilium:1.20.4@sha256:712e1f65bf30533d117d1996ac3ace3efdb2521302d31ee887b1e45806bd6b64
mv cilium cilium:1.20.4@sha256:712e1f65bf30533d117d1996ac3ace3efdb2521302d31ee887b1e45806bd6b64
cd ../..
ln -s _mirror/cilium/cilium:1.20.4@sha256:712e1f65bf30533d117d1996ac3ace3efdb2521302d31ee887b1e45806bd6b64 cilium
```

handy automation example
```sh
CHART_OCI_URL=oci://quay.io/cilium/charts/cilium
CHART_NAME=cilium
CHART_VERSION=1.20.4
CHART_SHA=sha256:712e1f65bf30533d117d1996ac3ace3efdb2521302d31ee887b1e45806bd6b64

cd k8s/charts

mkdir -p _mirror/${CAHRT_NAME}
cd _mirror/${CAHRT_NAME}

helm pull --untar ${CHART_OCI_URL}:${CHART_VERSION}@${CHART_SHA}
rm -rf ${CHART_NAME}:${CHART_VERSION}@${CHART_SHA}
mv ${CHART_NAME} ${CHART_NAME}:${CHART_VERSION}@${CHART_SHA}

cd ../..
rm ${CHART_NAME}
ln -s _mirror/${CHART_NAME}/${CHART_NAME}:${CHART_VERSION}@${CHART_SHA} ${CHART_NAME}
```
