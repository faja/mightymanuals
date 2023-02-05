resource "local_file" "path_module" {
  content  = "${path.module} ... test content ... bla bla bla"
  filename = "/tmp/file1.txt"
}

resource "local_file" "path_root" {
  content  = "${path.root} ... test content ... bla bla bla"
  filename = "/tmp/file2.txt"
}

resource "local_file" "reference_a_file_within_a_module" {
  content = templatefile("${path.module}/templates/t.txt", {})
  filename = "/tmp/file3.txt"
}

resource "local_file" "reference_a_file_outside_a_module" {
  content = templatefile("${path.root}/templates/t.txt", {})
  filename = "/tmp/file4.txt"
}
