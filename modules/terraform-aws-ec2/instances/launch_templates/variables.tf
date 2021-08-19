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
variable "image_id" {
  description = "Base image ID"
  type        = string
}
variable "instance_type" {
  description = "EC2 instance type to use"
  type        = string
}
variable "ec2_keypair" {
  description = "EC2 keypair to use"
  type        = string
  default     = null
}
variable "user_data" {
  description = "User data script to initialize servers"
  type        = string
  default     = null
}
variable "disable_api_termination" {
  description = "enables/disables EC2 Instance Termination Protection"
  type        = bool
  default     = false
}
variable "ebs_optimized" {
  description = "enables/disables EBS Optimization"
  type        = bool
  default     = false
}
variable "security_group_ids" {
  description = "List of Security Group IDs"
  type        = list(string)
  default     = null
}
variable "iam_role_name" {
  description = "EC2 IAM role name"
  type        = string
  default     = null
}
variable "shutdown_behavior" {
  description = "EC2 shutdown behavior"
  type        = string
  default     = "stop"
}
variable "enable_monitoring" {
  description = "Enable/Disable detailed monitoring"
  type        = bool
  default     = false
}
