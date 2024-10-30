resource "alicloud_instance" "http" {
  count                     = 2  
  availability_zone         = data.alicloud_zones.availability_zones.zones.0.id
  security_groups           = [alicloud_security_group.http.id]
  instance_type             = "ecs.g6.large"
  system_disk_category      = "cloud_essd"
  system_disk_size          = 40
  image_id                  = "ubuntu_24_04_x64_20G_alibase_20240812.vhd"
  instance_name             = "http-${count.index}"  
  vswitch_id                = alicloud_vswitch.private.id
  internet_max_bandwidth_out = 0
  instance_charge_type      = "PostPaid"
  key_name                  = "hananKey"

  user_data = base64encode(templatefile("http-setup.sh", { 
    redis_host = alicloud_instance.redis.private_ip,
    sql_host   = alicloud_instance.sql.private_ip
  }))
}

output "http_server_private_ips" {
  value = alicloud_instance.http.*.private_ip  
}
