resource "aws_lb_target_group" "tg" {
  name                 = "${var.name}-tg"
  port                 = var.port
  protocol             = var.protocol
  vpc_id               = var.vpc_id
  deregistration_delay = var.deregistration_delay
  target_type          = var.target_type

  health_check {
    port                = var.health_check_config.port
    protocol            = var.health_check_config.protocol
    interval            = var.health_check_config.interval_seconds
    path                = var.health_check_config.protocol == "TCP" ? null : var.health_check_config.path
    timeout             = var.health_check_config.protocol == "TCP" ? null : var.health_check_config.timeout_seconds
    enabled             = var.health_check_config.enabled
    healthy_threshold   = var.health_check_config.healthy_threshold
    unhealthy_threshold = var.health_check_config.unhealthy_threshold
    matcher             = var.health_check_config.protocol == "TCP" ? null : var.health_check_config.success_codes

  }

  stickiness {    
    type            = var.stickiness.type
    cookie_duration = var.stickiness.cookie_duration    
    enabled         = var.stickiness.enabled
  } 

  tags = merge({
    Name = "${var.name}-tg"
    },
  var.tags)
}
