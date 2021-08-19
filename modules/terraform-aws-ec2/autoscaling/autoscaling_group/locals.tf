locals {
  asg_tags = [for k, v in var.tags : {
    "key"                 = k
    "value"               = v
    "propagate_at_launch" = true
  } if k != "VERSION"]

}
