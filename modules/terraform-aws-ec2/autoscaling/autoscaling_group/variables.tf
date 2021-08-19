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
variable "desired_capacity" {
  description = "ASG desired capacity"
  type        = number
}
variable "min_size" {
  description = "ASG minimum capacity"
  type        = number
}
variable "max_size" {
  description = "ASG maximum capacity"
  type        = number
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}
variable "lt_id" {
  description = "Launch Template ID"
  type        = string
}
variable "lt_version" {
  description = "Launch Template version"
  type        = number
  default     = null
}
variable "enable_instance_refresh" {
  description = "Choose to force instance recycling when required"
  type        = bool
  default     = false
}
variable "healthy_percent" {
  description = "Percent of healthy instances availabel during refresh"
  type        = number
  default     = 100
}
variable "elb_id" {
  description = "ELB ID to associate ASG with"
  type        = string
  default     = null
}
variable "tg_arn" {
  description = "List of Target Group arn to associate ASG with"
  type        = list(string)
  default     = null
}
variable "wait_for_elb_capacity" {
  description = "Terraform will wait for exactly that number of Instances to be InService in all attached ELBs on both creation and updates"
  type        = bool
  default     = false
}
