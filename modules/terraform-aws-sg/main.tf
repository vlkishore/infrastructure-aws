resource "aws_security_group" "main" {
  count      = length(local.sec_grp)
  description = lookup(local.sec_grp[count.index], "description")

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = -1
    cidr_blocks     = [ "0.0.0.0/0" ]
  }
  ingress {
      from_port = 0
      to_port = 0
      protocol = -1
      self = true
  }
  dynamic "ingress" { 
    for_each = [ for r in local.sec_grp[count.index].ingress  : {
        cidr      = r.i_cidr
        from_port = r.i_from_port
        protocol  = r.i_protocol
        self      = "false"
        to_port   = r.i_to_port
        description = r.i_description
    }]
    content {
      cidr_blocks = ingress.value.cidr
      from_port   = ingress.value.from_port
      protocol    = ingress.value.protocol
      self        = ingress.value.self
      to_port     = ingress.value.to_port
      description = ingress.value.description
    }
  }
  
  name = lookup(local.sec_grp[count.index], "name")

  tags = merge({ Name = lookup(local.sec_grp[count.index], "name") },   var.tags )

  vpc_id = var.vpc_id

  timeouts {}
}

# resource "aws_security_group_rule" "main" {
#   # count      = length(local.sec_grp)
#   # depends_on               = [module.sg]
#   # count                    = length(module.sg.sec_grp_ids) 
#   for_each = [ for r in local.sec_grp[count.index].ingress  : {
#         cidr      = r.i_cidr
#         from_port = r.i_from_port
#         protocol  = r.i_protocol
#         self      = "false"
#         to_port   = r.i_to_port
#         description = r.i_description
#     }]
#   type                     = "ingress"
#   from_port                = each.key.from_port
#   to_port                  = each.key.to_port
#   protocol                 = each.key.protocol
#   cidr_blocks              = each.key.cidr 
#   description              = each.key.description
# }