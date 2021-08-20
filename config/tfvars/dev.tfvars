profile     = "terraform_nonprod"
region      = "us-east-1"
aws_account = "123456789"
role_arn    = null
external_id = null

name = "dev"
base_domain="kishore.com"
vpc_cidr = "10.0.0.0/16"

app = {
  stickiness_type         = "lb_cookie"
  stickiness_duration     = 86400
  stickiness_enabled      = false
  endpoint_values         = "example"
  instance_type           = "t2.micro"
  desired_capacity        = 1
  min_size                = 1
  max_size                = 1
  stop_at_offtime         = true
}

tags = {
  "Team"            = "DevOps"
  "Owner"           = "kishore"
  "ManagedBy"       = "Terraform"
}
