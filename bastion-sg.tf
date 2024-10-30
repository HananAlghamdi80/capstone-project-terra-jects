resource "alicloud_security_group" "bastion" {
  name        = "bastion"
  description = "Bastion security group for SSH access"
  vpc_id      = alicloud_vpc.vpc.id
}


resource "alicloud_security_group_rule" "allow_bastion_ssh" {
  type              = "ingress"
  ip_protocol       = "tcp"
  policy            = "accept"
  port_range        = "22/22"
  priority          = 1
  security_group_id = alicloud_security_group.bastion.id
  cidr_ip           = "0.0.0.0/0" # Allow access from any IP
}
