# auth - access entries

`access entries` is a concept of mapping IAM principal (user/role) to k8s permission.

- authentication - aka who is calling - k8s api extracts `principalArn` from the request - so it knows who is calling
- authorization - aka what permission to grat - this one can be configured in two ways:
    - with "access policies" - aws concept of granting preconfigured set of permissions:
      `AmazonEKSClusterAdminPolicy`, `AmazonEKSAdminPolicy`, `AmazonEKSEditPolicy`,
      `AmazonEKSViewPolicy` - run `aws eks list-access-policies`
    - with "group name" being mapped to `Role`/`ClusterRole` - this is more "classic" approach


## In practise

- access entry for "node"
    ```json
    resource "aws_eks_access_entry" "node" {
      cluster_name  = aws_eks_cluster.main.name
      principal_arn = aws_iam_role.eks-node.arn
      type          = "EC2_LINUX"
    }
    ```

- access entry for "admin"
    ```json
    resource "aws_eks_access_entry" "admin" {
      for_each = toset(var.eks_cluster_admin_arns)

      cluster_name  = aws_eks_cluster.main.name
      principal_arn = each.value
      type          = "STANDARD"
    }

    resource "aws_eks_access_policy_association" "admin" {
      for_each = aws_eks_access_entry.admin

      cluster_name  = aws_eks_cluster.main.name
      principal_arn = each.value.principal_arn
      policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

      access_scope {
        type = "cluster"
      }
    }

    # arn notes:
    #   - for user this is just user arn, eg: arn:aws:iam::111122223333:user/${user}
    #   - for roles this is the role arn, eg: arn:aws:iam::111122223333:role/${rolename}
    #       not actually the caller identiy you get from sts get-caller-identity
    ```

- access entry for "user"
    ```
    resource "aws_eks_access_entry" "user" {
      cluster_name  = aws_eks_cluster.main.name
      principal_arn = ${arn}
      type          = "STANDARD"
      # kubernetes_groups = [] # I usually do not use these
    }

    resource "aws_eks_access_policy_association" "user" {
      cluster_name  = aws_eks_cluster.main.name
      principal_arn = aws_eks_access_entry.user.principal_arn
      policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"

      access_scope {
        type = "namespace"
        namespaces = [...]
      }
    }

    # note: a user can have all resources `Deny` to access k8s,
    #       but to be able to run update-kubeconfig, it must have `eks:DescribeCluster`
    #       action allowed, so usually that's what you want
    ```


## tips and trics
- how to add eks to `.kube/config`
```sh
aws --profile ${profile} sts get-caller-identity
aws --profile ${profile} eks list-clusters
aws --profile ${profile} eks update-kubeconfig --name ${cluster_name} \
  --region ${region} --alias my_short_name
```

```sh
# if we use different role as a k8s principal

# ~/.aws/config
[profile base]
...# this is our base role

[profile eks-sre]
role_arn = arn:aws:iam::111122223333:role/platform-sre # this one is used as k8s principal
source_profile = base

# then run
aws --profile ${profile} eks update-kubeconfig --name ${cluster_name} \
  --region ${region} --role arn:aws:iam::111122223333:role/platform-sre

```
