- first of all, obvious thing, if we referance path variables in root config directory
  - `${path.module}` = `.`
  - `${path.root}` = `.`
- in 'local/filesystem' modules
  - `${path.module}` = `path/to/module`
  - `${path.root}` = `.`
- in 'git' modules
  - `${path.module}` = `.terraform/modules/path_module_inside_a_module_from_git`
  - `${path.root}` = `.`

# so
- if we have a module, in that module, we have a `templates` directory, and you want to referenc to some file in that directory use `${path.module}`, eg:
```
resource "local_file" "reference_a_file_within_a_module" {
  content = templatefile("${path.module}/templates/t.txt", {})
  filename = "/tmp/file3.txt"
}
```
this will look for a file `templates/t.txt` located in the MODULE!

- if we have a module, that references some files **OUTSIDE** it, use `${path.root}` variable, eg:
```hcl

resource "local_file" "reference_a_file_outside_a_module" {
  content = templatefile("${path.root}/templates/t.txt", {})
  filename = "/tmp/file4.txt"
}
```
this will look for a file `templates/t.txt` located in the root terraform config path
