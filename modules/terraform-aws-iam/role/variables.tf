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
variable "service" {
  description = "AWS Service Principal"
  type        = string
}
variable "custom_policy" {
  description = "Custom IAM policy document in json format"
  type        = string
  default     = null
}
variable "aws_managed_policy" {
  description = "List of ARNs of AWS managed IAM policy"
  type        = list(string)
  default     = null
}
