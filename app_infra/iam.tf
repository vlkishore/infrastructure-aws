data "aws_iam_policy_document" "policy" {
  statement {
    actions   = ["*"]
    resources = ["*"]
  }
}



module "ec2_role" {
  source = "../modules/terraform-aws-iam/role"
  name           = "ec2.${var.name}"
  description    = "IAM default role for EC2 instances"
  service        = "ec2.amazonaws.com"
  aws_managed_policy = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  tags = var.tags
}
