# this is basically todo ..but 1 thing

## sharing locals between parent and child terragrunt hcl files
### fetching locals from included file
- parent `root.hcl`
    ```hcl
    locals {
        global_base_url = "xyz"
    }
    ```
- child `app/terragrunt.hcl`
    ```hcl
    include "root" {
        path = find_in_parent_folders("root.hcl")
        expose = true
    }

    // now we can access ${include.root.locals.global_base_url} variable
    ```

### pushing locals to included file
- child `app/terragrunt.hcl`
    ```hcl
    locals {
        my_custom_env = "ok"
    }
    ```
- parent `root.hcl`
    ```hcl

    locals {
        local_from_child = read_terragrunt_config(find_in_parent_folders("terragrunt.hcl"))
    }

    // now ${local.local_from_child.locals.my_custom_env} variable should be accessible
    ```

## example magic stuff

```hcl
locals {
  jobs_config = yamldecode(file("jobs.yaml")).jobs
  jobs = keys(local.jobs_config)
  job1 = yamldecode(file("values-job1.yaml"))
}

generate "ttt" {
  if_exists = "overwrite_terragrunt"
  path = "x.tf"
  contents = <<-EOF
      //ok
      output "ok" {
        value = "${local.jobs_config["job1"].some_param}"
      }
  EOF
}
```
