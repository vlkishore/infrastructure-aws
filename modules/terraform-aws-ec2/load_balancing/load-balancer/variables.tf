# Common variables
variable "aws_account" {
  description = "AWS account number"
  type        = string
}
variable "tags" {
  description = "Map of resource tags"
  type        = map(string)
  default     = { "Name" = "terraform-default" }
}
variable "name" {
  description = "Name prefix for reource naming."
  type        = string
}


# Module specific variables
variable "elb_type" {
  description = "Load Balancer Type. Only application/network is supported"
  type        = string
  default     = "application"
}
variable "internal" {
  description = "If the LB should be Private or Public facing"
  type        = bool
  default     = true
}
variable "security_group_ids" {
  description = "List of Security Group IDs"
  type        = list(string)
}
variable "subnet_ids" {
  description = "List of Subnet IDs"
  type        = list(string)
}
variable "vpc_id" {
  description = "VPC ID in which the target group to be created"
  type        = string
}
variable "access_logs" {
  description = "Acess logs configuration"
  type = object({
    bucket  = string
    enabled = bool
  })
  default = null
}
variable "listners_redirect" {
  description = "List of parameters for listner of type redirect"
  type = list(object({
    lsn_port     = number
    fwd_port     = number
    lsn_protocol = string
    fwd_protocol = string
    status_code  = string
    host         = string
    path         = string
    query        = string
  }))
  default = null
}

variable "listners_fwd" {
  description = "List of parameters for HTTPS listner"
  type = list(object({
    port         = number
    protocol     = string
    tg_arn       = string
    ssl_policy   = string
    ssl_cert_arn = string
  }))
  default = null
}

variable "listners_main" {
  description = "List of parameters for listner of type fixed response"
  type = list(object({
    lsn_port     = number
    lsn_protocol = string
    tg_arn       = string
    ssl_policy   = string
    ssl_cert_arn = string
  }))
  default = null
}