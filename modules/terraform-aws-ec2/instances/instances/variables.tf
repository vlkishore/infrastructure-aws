# Common variables
variable "tags" {
  description = "Map of resource tags"
  type        = map(string)
  default     = { "Name" = "terraform-default" }
}

# Module specific variables
variable "name" {
  description = "Instance name. Prefix will be added automatically by name_prefix variable"
  type        = string
}
variable "ami_id" {
  description = "The AMI to use for the instance."
  type        = string
}
variable "instance_type" {
  description = ""
  type        = string
}
variable "disable_api_termination" {
  description = "enables/disables EC2 Instance Termination Protection"
  type        = bool
  default     = false
}
variable "shutdown_behavior" {
  description = "Shutdown behavior for the instance"
  type        = string
  default     = "stop"
}
variable "keypair" {
  description = "The key name of the Key Pair to use for the instance"
  type        = string
  default     = null
}
variable "monitoring" {
  description = "enable/disable detailed monitoring"
  type        = bool
  default     = false
}
variable "vpc_config" {
  description = "VPC configuration with exact fields as shows below."
  type = object({
    security_group_ids = list(string)
    subnet_id          = string
  })
}
# variable "network_interface" {
#   description = "setting up network interfaces."
#   # type = object({
#   #   network_interface_id = number
#   #   device_index          = string
#   # })
# }
variable "private_ip" {
  description = "setting up private_ips."
}
variable "user_data" {
  description = "User data script to initialize servers"
  type        = string
  default     = null
}
variable "iam_role_name" {
  description = "EC2 IAM role name"
  type        = string
  default     = null
}
