
resource "aws_security_group" "developers" {
  name        = "{{ .config.prefix }}-developers"
  description = "SSH Access"
  vpc_id      = "{{ .output.net.main.vpc_id }}"
  tags = {
    Name = "{{ .config.prefix }}-developers"
  }
}

resource "aws_security_group_rule" "developers-i" {
  type              = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = [{{ .output.net.main.public_subnet_cidrs }}, "185.46.20.32/28"]
  security_group_id = aws_security_group.developers.id
}
