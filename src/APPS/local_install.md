---

- [cilium-cli](#cilium-cli)
- [kind](#kind)


### cilium-cli
- [version url](https://github.com/cilium/cilium-cli?tab=readme-ov-file#releases)
- install commands:
```sh
VERSION=0.18.3
curl -L -o /tmp/cilium.tar.gz https://github.com/cilium/cilium-cli/releases/download/v${VERSION}/cilium-linux-amd64.tar.gz
tar -C ~/bin2 -xzvf /tmp/cilium.tar.gz
cilium version

```
### kind
- [version url](https://github.com/kubernetes-sigs/kind/releases)
- install commands:
```sh
VERSION=0.29.0
curl -L -o ~/bin2/kind https://github.com/kubernetes-sigs/kind/releases/download/v${VERSION}/kind-linux-amd64
chmod a+x ~/bin2/kind
kind version
```
---

# old stuff, to be cleaned up...

### helm-sops
- my current version: 20201003-1
- version url: https://github.com/camptocamp/helm-sops/releases
- install commands:
```
VERSION=20201003-1
curl -L -o /tmp/helm-sops.tar.gz https://github.com/camptocamp/helm-sops/releases/download/${VERSION}/helm-sops_${VERSION}_linux_amd64.tar.gz
tar -xvf /tmp/helm-sops.tar.gz -C /tmp
mv /tmp/helm-sops ~/bin2/helm-sops
helm-sops version --short
```

### okteto
- my current version: 1.10.5
- version url: https://github.com/okteto/okteto/releases
- install commands:
```
VERSION=1.10.5
curl -L -o ~/bin2/okteto https://github.com/okteto/okteto/releases/download/${VERSION}/okteto-Linux-x86_64
chmod a+x ~/bin2/okteto
```

### dive
- my current version: 0.9.2
- version url: https://github.com/wagoodman/dive/releases
- install commands:
```
VERSION=0.9.2
curl -L -o /tmp/dive.tar.gz https://github.com/wagoodman/dive/releases/download/v${VERSION}/dive_${VERSION}_linux_amd64.tar.gz
tar -xvf /tmp/dive.tar.gz -C /tmp
mv /tmp/dive ~/bin2/dive
dive --version
```

### tfsec
- version url: https://github.com/aquasecurity/tfsec/releases
- install commands:
```
VERSION=0.45.4
curl -L -o /tmp/tfsec https://github.com/tfsec/tfsec/releases/download/v${VERSION}/tfsec-linux-amd64
chmod a+x /tmp/tfsec
mv /tmp/tfsec ~/bin2/tfsec
tfsec --version
```

### tflint
- version url: https://github.com/terraform-linters/tflint/releases
- install commands:
```
VERSION=0.30.0
curl -L -o /tmp/tflint.zip https://github.com/terraform-linters/tflint/releases/download/v${VERSION}/tflint_linux_amd64.zip
unzip /tmp/tflint.zip -d /tmp
mv /tmp/tflint ~/bin2/tflint
tflint --version
```

