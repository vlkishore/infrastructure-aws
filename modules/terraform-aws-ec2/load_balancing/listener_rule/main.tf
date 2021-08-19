
resource "aws_lb_listener_rule" "main" {
  count = var.listener_rule != null ? 1 : 0
  listener_arn = var.listener_rule.listener_arn
  # priority     = 99

  action {
    type             = "forward"
    target_group_arn = var.listener_rule.target_group_arn
  }

  condition {
    host_header {
      values = var.listener_rule.endpoint_values 
    }
  }
  
}