
module "tg_app" {
  source = "../modules/terraform-aws-ec2/load_balancing/target_group"
  name                 = "${var.name}-app"
  vpc_id               = module.vpc.id
  port                 = 80
  protocol             = "HTTP"
  deregistration_delay = 60

  health_check_config = {
    port                = "traffic-port"
    protocol            = "HTTP"
    interval_seconds    = "10"
    path                = "/"
    timeout_seconds     = "5"
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    success_codes       = "200"
  }
  tags = var.tags

  stickiness = {    
    type            = var.app.stickiness_type    
    cookie_duration = var.app.stickiness_duration    
    enabled         = var.app.stickiness_enabled 
  } 
}

module "lt_app" {
  source = "../modules/terraform-aws-ec2/instances/launch_templates"
  name               = "${var.name}.app"
  image_id           = data.aws_ami.app.id
  instance_type      = var.app.instance_type
  ec2_keypair        = aws_key_pair.main.key_name
  user_data          = base64encode(data.template_file.app.rendered)
  iam_role_name      = module.ec2_role.role["NAME"]
  security_group_ids = [ aws_security_group.app.id]
  tags = var.tags

}

module "asg_app" {
  depends_on = [  module.elb  ]
  source = "../modules/terraform-aws-ec2/autoscaling/autoscaling_group"
  name               = "${var.name}.app"
  enable_instance_refresh = false
  desired_capacity        = var.app.desired_capacity
  min_size                = var.app.min_size
  max_size                = var.app.max_size
  subnet_ids              = module.vpc.public_subnets
  tg_arn                = [module.tg_app.tg["ARN"]]
  wait_for_elb_capacity = false // for just initial deployment

  lt_id      = module.lt_app.lt["ID"]
  lt_version = module.lt_app.lt_latest_version
  
  tags = var.tags
}

