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

variable "listener_rule" {
  description = "List of parameters for listener_rule"
  type = object({
    listener_arn       = string
    listener_arn       = string
    target_group_arn   = string
    endpoint_values    = list(string)
  })
  default = null
}