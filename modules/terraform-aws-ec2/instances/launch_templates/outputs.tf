output "lt_latest_version" {
  description = "The latest version of the launch template."
  value       = aws_launch_template.lt.latest_version
}

output "lt" {
  description = "Launch Template properties"
  value = {
    "NAME" = "${var.name}-lt"
    "ID"   = aws_launch_template.lt.id
    "ARN"  = aws_launch_template.lt.arn
  }
}
