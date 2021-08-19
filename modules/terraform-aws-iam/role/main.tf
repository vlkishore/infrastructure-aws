resource "aws_iam_role" "role" {
  name        = "${var.name}-role"
  description = var.description != null ? var.description : null

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "${var.service}"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF

  tags = merge({
    Name = "${var.name}-role"
    },
    var.tags
  )
}

# Add custom policy
resource "aws_iam_role_policy" "custom_policy" {
  count  = var.custom_policy != null ? 1 : 0
  name   = "${var.name}-role-policy"
  role   = aws_iam_role.role.id
  policy = var.custom_policy

}

# Attach AWS managed policies
resource "aws_iam_role_policy_attachment" "aws_managed_policy" {
  count      = var.aws_managed_policy != null ? length(var.aws_managed_policy) : 0
  role       = aws_iam_role.role.name
  policy_arn = element(var.aws_managed_policy, count.index)
}
