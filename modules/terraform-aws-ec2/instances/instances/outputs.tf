output "instance" {
  description = "Instance properties"
  value = {
    "NAME"        = "${var.name}-instance"
    "ID"          = aws_instance.instance.id
    "ARN"         = aws_instance.instance.arn
    "PRIVATE_DNS" = aws_instance.instance.private_dns
    "PRIVATE_IP"  = aws_instance.instance.private_ip
    "PUBLIC_DNS"  = aws_instance.instance.public_dns
    "PUBLIC_IP"   = aws_instance.instance.public_ip
  }
}
