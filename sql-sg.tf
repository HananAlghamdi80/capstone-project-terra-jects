resource "alicloud_security_group" "sql" {
  name        = "sql"
  description = "SQL Server security group"
  vpc_id      = alicloud_vpc.vpc.id
}

resource "alicloud_security_group_rule" "allow_bastion_to_sql_ssh" {
  type                     = "ingress"
  ip_protocol              = "tcp"
  policy                   = "accept"
  port_range               = "22/22"
  priority                 = 1
  security_group_id        = alicloud_security_group.sql.id
  source_security_group_id = alicloud_security_group.bastion.id
}

resource "alicloud_security_group_rule" "allow_web_to_sql" {
  type                     = "ingress"
  ip_protocol              = "tcp"
  policy                   = "accept"
  port_range               = "3306/3306"  # Default SQL Server port
  priority                 = 1
  security_group_id        = alicloud_security_group.sql.id
  source_security_group_id = alicloud_security_group.http.id
}
