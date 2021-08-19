resource "aws_iam_instance_profile" "iam_instance_profile" {
  count = var.iam_role_name != null ? 1 : 0
  name  = "${var.name}-iam-profile"
  role  = var.iam_role_name
}

resource "aws_launch_template" "lt" {
  name = "${var.name}-lt"

  image_id                             = var.image_id
  instance_type                        = var.instance_type
  key_name                             = var.ec2_keypair != null ? var.ec2_keypair : null
  user_data                            = var.user_data != null ? var.user_data : null
  disable_api_termination              = var.disable_api_termination
  ebs_optimized                        = var.ebs_optimized
  vpc_security_group_ids               = var.security_group_ids != null ? var.security_group_ids : null
  instance_initiated_shutdown_behavior = var.shutdown_behavior


  iam_instance_profile { name = aws_iam_instance_profile.iam_instance_profile[0].name }
  monitoring { enabled = var.enable_monitoring }


  tag_specifications {
    resource_type = "instance"

    tags = merge({
      Name = "${var.name}-lt"
      },
    var.tags)
  }

  tags = merge({
    Name = "${var.name}-lt"
    },
    var.tags
  )



}
