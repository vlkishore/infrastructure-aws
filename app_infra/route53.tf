# module "route53" {
#   source = "../modules/terraform-aws-route53/zone"

#   hosted_domain_name = "${terraform.workspace}.${var.base_domain}"

#   tags = merge({
#     Name = "${terraform.workspace}-hz"
#     },
#     var.tags
#   )
# }