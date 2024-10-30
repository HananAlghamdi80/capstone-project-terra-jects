resource "alicloud_instance" "sql" {
  availability_zone         = data.alicloud_zones.availability_zones.zones.0.id
  security_groups           = [alicloud_security_group.sql.id]

  host_name                 = "sql"

  # series III
  instance_type             = "ecs.g6.large"
  system_disk_category      = "cloud_essd"
  system_disk_size          = 40
  image_id                  = "ubuntu_24_04_x64_20G_alibase_20240812.vhd"
  instance_name             = "sql"
  vswitch_id                = alicloud_vswitch.private.id
  internet_max_bandwidth_out = 0
  internet_charge_type      = "PayByTraffic"
  instance_charge_type      = "PostPaid"
  key_name                  = "hananKey"

  user_data = base64encode(file("sql-setup.sh"))
}

output "sql_private_ip" {
  value = alicloud_instance.sql.private_ip
}
