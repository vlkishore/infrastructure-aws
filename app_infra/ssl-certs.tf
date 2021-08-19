# module "ssl-cert" {
#   source = "../modules/terraform-aws-acm"
#   depends_on = [module.route53]
#   domain_name    = "${terraform.workspace}.${var.base_domain}"
#   san            = ["*.${terraform.workspace}.${var.base_domain}"]
#   zone_id        = var.route53_zone_id
#   tags = merge({
#     Name = "${terraform.workspace}.${var.base_domain}"
#     },
#     var.tags
#   )
# }

resource "tls_private_key" "self_cert" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "self_cert" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.self_cert.private_key_pem

  subject {
    common_name  = var.base_domain
    organization = "ACME Examples, Inc"
  }

  validity_period_hours = 12

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "self_cert" {
  private_key      = tls_private_key.self_cert.private_key_pem
  certificate_body = tls_self_signed_cert.self_cert.cert_pem
}