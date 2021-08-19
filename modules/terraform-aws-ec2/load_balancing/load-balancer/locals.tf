locals {
  name = var.elb_type == "network" ? "${var.name}-nlb" : "${var.name}-alb"

}
