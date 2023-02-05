module "job" {
  source = "../spec"

  save_spec_file = true

  values = [
    yamldecode(file("values.yaml")),
    yamldecode(file("valuesVersion.yaml")),
    {
      count: 2
    },
  ]
}

// we save the output specfile, so there is no point of output
// output "jobspec" {
//   value = module.job.jobspec
// }
