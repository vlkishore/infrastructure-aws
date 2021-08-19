# Common variables
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
variable "vpc_id" {
  description = "VPC ID in which the target group to be created"
  type        = string
}
variable "port" {
  description = "The port on which targets receive traffic"
  type        = number
}
variable "target_type" {
  description = "Target registration type. One of the - instance, ip, lambda"
  type        = string
  default     = "instance"
}
variable "protocol" {
  description = "The protocol to use for routing traffic to the targets"
  type        = string
}
variable "deregistration_delay" {
  description = "The amount time (seconds) for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused"
  type        = number
  default     = 300
}
variable "health_check_config" {
  description = "A Health Check block"
  type = object({
    port                = string
    protocol            = string
    interval_seconds    = number
    path                = string
    timeout_seconds     = number
    enabled             = bool
    healthy_threshold   = number
    unhealthy_threshold = number
    success_codes       = number
  })
}

variable "stickiness" {
  description = "List of parameters for stickiness"
  type = object({
    type             = string
    cookie_duration  = string
    enabled          = bool
  })
  default = {
    type             = "lb_cookie"
    cookie_duration  = 0
    enabled          = false
  }
}