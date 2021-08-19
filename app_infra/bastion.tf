# data "aws_ami" "bastion" {
#   most_recent = true
#   filter {
#     name   = "name"
#     values = ["amzn2-ami-hvm*"]
#   }
#   filter {
#     name   = "architecture"
#     values = ["x86_64"]
#   }
#   filter {
#     name   = "block-device-mapping.volume-type"
#     values = ["gp2"]
#   }
#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
#   owners = ["amazon"]
# }

# data "aws_ami" "this" {
#   filter {
#     name   = "tag:id"
#     values = [null_resource.packer.id]
#   }

#   most_recent = true
#   owners      = ["self"]
# }

# module "bastion" {
#   source = "../modules/terraform-aws-ec2/instances/instances"
#   depends_on     = [module.vpc]
#   name           = "${var.name}${terraform.workspace}-bastion"
#   ami_id         = data.aws_ami.bastion.id
#   instance_type  = "t2.micro"
#   keypair        = aws_key_pair.main.key_name
#   iam_role_name  = module.ec2_role.role["NAME"]
#   private_ip     = null
#   vpc_config = {
#     security_group_ids = [aws_security_group.bastion.id],
#     subnet_id          = element(module.vpc.public_subnets, 0)
#   }
#   tags = var.tags
# }

# resource "aws_eip" "bastion" {
#   depends_on                = [module.vpc,module.bastion]
#   vpc                       = true
#   instance                  = module.bastion.instance["ID"]
#   associate_with_private_ip = module.bastion.instance["PRIVATE_IP"]

#   tags = merge({
#     Name = "${var.name}${terraform.workspace}-bastion-eip"
#     },
#     var.tags
#   )
# }

# #resource "aws_eip_association" "eip_bastion" {
# #  depends_on                = [module.vpc,module.bastion]
# #  instance_id   = module.bastion.instance["ID"]
# #  allocation_id = element(module.vpc.nat_eip_ids,0)
# #}

# resource "null_resource" "openvpn_bootstrap" {
#   #depends_on                = [aws_eip_association.eip_bastion]
#   depends_on                = [aws_eip.bastion]
#   connection {
#     type        = "ssh"
#     host        = aws_eip.bastion.public_ip
#     user        = var.ec2_username
#     port        = "22"
#     private_key = file("../config/ssh-keys/${var.name}${terraform.workspace}.pem")
#     agent       = false
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "sudo yum update -y",
#       "curl -O ${var.openvpn_install_script_location}",
#       "chmod +x openvpn-install.sh",
#       <<EOT
#       sudo AUTO_INSTALL=y \
#            APPROVE_IP=${aws_eip.bastion.public_ip} \
#            ENDPOINT=${aws_eip.bastion.public_dns} \
#            ./openvpn-install.sh
      
# EOT
#       ,
#     ]
#   }
# }

# resource "null_resource" "openvpn_update_users_script" {
#   depends_on = [null_resource.openvpn_bootstrap]

#   triggers = {
#     ovpn_users = join(" ", var.ovpn_users)
#   }

#   connection {
#     type        = "ssh"
#     host        = module.bastion.instance["PUBLIC_IP"]
#     user        = var.ec2_username
#     port        = "22"
#     private_key = file("../config/ssh-keys/${var.name}${terraform.workspace}.pem")
#     agent       = false
#   }

#   provisioner "file" {
#     source      = "${path.module}/userdata/update_users.sh"
#     destination = "/home/${var.ec2_username}/update_users.sh"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "chmod +x ~${var.ec2_username}/update_users.sh",
#       "sudo ~${var.ec2_username}/update_users.sh ${join(" ", var.ovpn_users)}",
#     ]
#   }
# }

# resource "null_resource" "openvpn_download_configurations" {
#   depends_on = [null_resource.openvpn_update_users_script]

#   triggers = {
#     ovpn_users = join(" ", var.ovpn_users)
#   }

#   provisioner "local-exec" {
#     command = <<EOT
#     mkdir -p ${var.ovpn_config_directory};
#     scp -o StrictHostKeyChecking=no \
#         -o UserKnownHostsFile=/dev/null \
#         -i ../config/ssh-keys/${var.name}${terraform.workspace}.pem ${var.ec2_username}@${aws_eip.bastion.public_ip}:/home/${var.ec2_username}/*.ovpn ${var.ovpn_config_directory}/
    
# EOT

#   }
# }
