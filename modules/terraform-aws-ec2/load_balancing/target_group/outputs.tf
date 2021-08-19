output "tg" {
  description = "Target Group properties"
  value = {
    "NAME" = "${var.name}-tg"
    "ID"   = aws_lb_target_group.tg.id
    "ARN"  = aws_lb_target_group.tg.arn
  }
}
