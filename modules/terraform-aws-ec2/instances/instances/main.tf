resource "aws_iam_instance_profile" "iam_instance_profile" {
  count = var.iam_role_name != null ? 1 : 0
  name  = "${var.name}-iam-profile"
  role  = var.iam_role_name
}

resource "aws_instance" "instance" {
  ami                                  = var.ami_id
  disable_api_termination              = var.disable_api_termination
  instance_type                        = var.instance_type
  instance_initiated_shutdown_behavior = var.shutdown_behavior
  key_name                             = var.keypair != null ? var.keypair : null
  monitoring                           = var.monitoring
  user_data                            = var.user_data != null ? var.user_data : null
  iam_instance_profile                 = var.iam_role_name != null ? aws_iam_instance_profile.iam_instance_profile[0].name : null
  vpc_security_group_ids               = var.vpc_config.security_group_ids
  subnet_id                            = var.vpc_config.subnet_id
  private_ip                           = var.private_ip == null ? null : var.private_ip
  # dynamic "network_interface" {
  #   for_each = var.network_interface == "" ? [] : [1]
  #    content {
  #     network_interface_id = var.network_interface.network_interface_id
  #     device_index =  var.network_interface.device_index
  #    }     
  # }
  tags = merge({
    Name = "${var.name}-instance"
    },
    var.tags
  )
}
