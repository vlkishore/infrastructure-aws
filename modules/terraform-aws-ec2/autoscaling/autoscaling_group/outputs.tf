output "asg" {
  description = "Autoscaling Group properties"
  value = {
    "NAME" = aws_autoscaling_group.asg.name
    "ID"   = aws_autoscaling_group.asg.id
    "ARN"  = aws_autoscaling_group.asg.arn
    "TAGS"  = aws_autoscaling_group.asg.tags
  }
}
