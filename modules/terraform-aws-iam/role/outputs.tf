output "role" {
  description = "AWS IAM role properties"
  value = {
    "NAME" = "${var.name}-role"
    "ID"   = aws_iam_role.role.id
    "ARN"  = aws_iam_role.role.arn
  }
}
