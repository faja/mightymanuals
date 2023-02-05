locals {
  hour = 1
  day  = local.hour * 24
}

resource "tls_private_key" "default" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_self_signed_cert" "default" {
  private_key_pem = tls_private_key.default.private_key_pem

  subject {
    common_name  = "xyzzy.com"
  }

  validity_period_hours = 7 * local.day

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

locals {
  pem = "${tls_self_signed_cert.default.cert_pem}${tls_private_key.default.private_key_pem}"
}

output "key" {
  value = tls_private_key.default.private_key_pem
  sensitive = true
}

output "crt" {
  value = tls_self_signed_cert.default.cert_pem
  sensitive = true
}

output "pem" {
  value = local.pem
  sensitive = true
}

//resource "local_file" "pem" {
//  content         = local.pem
//  filename        = "server.pem"
//  file_permission = "0600"
//}
