# Common variables
variable "tags" {
  description = "Map of resource tags"
  type        = map(string)
  default     = { "Name" = "terraform-default" }
}

# Module specific variables
variable "name" {
  description = "Name of the resource"
  type        = string
}
variable "description" {
  description = "description / comment for the resource"
  type        = string
  default     = null
}

variable "vpc_id" {}

variable "security_groups" {
    type    = map
    default = {}
}

