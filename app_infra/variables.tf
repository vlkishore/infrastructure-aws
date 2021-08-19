variable "profile" {
  type    = string
}
variable "aws_account" {
  description = "AWS account number"
  type        = string
}
variable "role_arn" {
  type    = string
}

variable "external_id" {
  type    = string
}

variable "region" {
  default = "us-east-1"
}

variable "name" {
  default = "dev"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}


variable "allowed_cidrs" {
  type    = list
  default = []
}

variable "base_domain" {
  description = "Base domain name to be used for all DNS records"
  default     = ""
}

variable "security_groups" {
    type    = map
    default = {}
}

variable "tags" {
  type    = map
  default = {}
}


variable "app" {}