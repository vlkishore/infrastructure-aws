locals {
    sec_grp = flatten([
       for sg in keys(var.security_groups) : [          
          for ss in var.security_groups[sg]: {
            i_count       = length(ss.ingress)
            name          = "${var.name}-${sg}"
            description   = "${var.name}-${sg}" //ss.description
            ingress       = [ for i in ss.ingress : {
              i_cidr        = i.cidr_blocks
              i_from_port   = i.from_port
              i_protocol    = i.protocol
              i_to_port     = i.to_port
              i_description = i.description
            }]              
      }]     
    ])
}