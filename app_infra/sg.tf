resource "aws_security_group" "app" {
  name        = "${var.name}-app-sg"
  description = "Default security group for app tier"
  vpc_id      = module.vpc.id
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = -1
    cidr_blocks     = [ "0.0.0.0/0" ]
  }
  tags = merge({
    Name = "${var.name}-app-sg"
    },
    var.tags
  )
}
resource "aws_security_group_rule" "ssh_app" {
  description       = "Allow SSH from anywhere"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.app.id
}
resource "aws_security_group_rule" "http_app" {
  description       = "Allow SSH from anywhere"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.app.id
}
resource "aws_security_group_rule" "https_app" {
  description       = "Allow SSH from anywhere"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.app.id
}