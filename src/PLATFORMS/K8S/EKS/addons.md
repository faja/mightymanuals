# ADDONS

```sh
aws --profile xyzzy eks describe-addon-versions --addon-name aws-ebs-csi-driver --kubernetes-version 1.37  --query 'addons[0].addonVersions[0].addonVersion' --output text
aws --profile xyzzy eks describe-addon-configuration --addon-name aws-ebs-csi-driver --addon-version v1.68.0-eksbuild.1 | jq -r .configurationSchema | jq .
```

