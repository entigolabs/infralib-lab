

module "studenthosts" {
  count = 13
  source                 = "git::https://github.com/entigolabs/entigo-infralib-release.git//modules/aws/ec2?ref=v1.0.15"
  prefix                 = "infralib-infralib-u${count.index + 1}"
  route53_name           = "infralib-${count.index + 1}"
  route53_zone_id        = "Z0854848C083DV8BKUYJ"
  security_group_ingress = {
all = {
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}
}
  subnet_id              = [{{ .toutput.vpc.public_subnets }}][0]
  instance_type          = "t3.medium"
  key_name               = "martivo-x220"
  public_ip_address      = true
}
