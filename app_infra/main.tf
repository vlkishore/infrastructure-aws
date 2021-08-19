locals {
  # ami_name = join("-", ["${var.name}-app-ami", formatdate("YYYYMMDDhhmmss", timestamp())])
  ami_name = "${var.name}-app-ami"
  ssh_username = "ubuntu"
}
module "vpc" {
  source                 = "../modules/terraform-aws-vpc"
  cidr                   = var.vpc_cidr
  name                   = "${var.name}"
  provision_nat          = false
  nat_per_az             = false
  separate_db_subnets    = false
  subnet_outer_offsets   = [ 4, 2, 6 ]
  subnet_inner_offsets   = [ 2, 2 ]
  transit_gateway_attach = false
  transit_gateway_id     = ""
  allow_cidrs_default    = {}
  tags = var.tags

  public_subnet_tags = var.tags

  private_subnet_tags = var.tags
}

resource "tls_private_key" "main" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "main" {
  key_name   = "${var.name}"
  public_key = tls_private_key.main.public_key_openssh

  provisioner "local-exec" { 
    # inline = [
    #     "echo '${tls_private_key.main.private_key_pem}' > ../config/ssh-keys/${var.name}.pem",
    #     "chmod 600 ../config/ssh-keys/${var.name}.pem"
    # ]
    command = "echo '${tls_private_key.main.private_key_pem}' > ../config/ssh-keys/${var.name}.pem"
  }
}

resource "null_resource" "packer" {
  triggers = {
    ami_name = local.ami_name
  }
  provisioner "local-exec" {
    working_dir = "../packer"
  # command = "packer build image.pkr.hcl"
    command = <<EOF
packer build \
  -var name=${local.ami_name} \
  -var profile=${var.profile} \
  -var vpc_id=${module.vpc.id} \
  -var subnet_id=${element(module.vpc.public_subnets, 0)} \
  -var id=${self.id} \
  -var ssh_username=${local.ssh_username} \
  packer-build.json

EOF
  }
}

module "elb" {
  source = "../modules/terraform-aws-ec2/load_balancing/load-balancer"
  depends_on = [ module.tg_app  ]
  aws_account        = var.aws_account
  name               = "${var.name}"
  subnet_ids         = module.vpc.public_subnets
  security_group_ids = [aws_security_group.app.id ]
  elb_type           = "application"
  internal           = false
  vpc_id             = module.vpc.id

  listners_main = [
    {
      lsn_port         = 443
      lsn_protocol     = "HTTPS"      
      ssl_policy       = "ELBSecurityPolicy-2016-08"
      ssl_cert_arn     = aws_acm_certificate.self_cert.arn
      tg_arn           = module.tg_app.tg["ARN"]
    }
  ]
  listners_redirect = [
    {
      lsn_port     = 80
      fwd_port     = 443
      lsn_protocol = "HTTP"
      fwd_protocol = "HTTPS"
      status_code  = "HTTP_301"
      host         = "#{host}"
      path         = "#{path}"
      query        = "#{query}"
    }
  ]

  tags = var.tags
}