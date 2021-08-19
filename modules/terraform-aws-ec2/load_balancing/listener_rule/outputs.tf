# output "elb" {
#   description = "Load Balancer properties"
#   value = {
#     "NAME"     = local.name
#     "ID"       = aws_lb.elb.id
#     "ARN"      = aws_lb.elb.arn
#     "DNS_NAME" = aws_lb.elb.dns_name
#   }
# }

# output "listener" {
#   description = "Main Listener 443 properties"
#   value = {
#     "ARN"      = aws_laws_lb_listenerb.listners_main.arn
#   }
# }
