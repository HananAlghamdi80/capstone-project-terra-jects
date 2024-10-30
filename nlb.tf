
resource "alicloud_nlb_load_balancer" "http" {
  load_balancer_name = "http-nlb"
  load_balancer_type = "Network"
  address_type       = "Internet"
  address_ip_version = "Ipv4"
  vpc_id             = alicloud_vpc.vpc.id

  
  zone_mappings {
    vswitch_id = alicloud_vswitch.public.id
    zone_id    = data.alicloud_zones.availability_zones.zones.0.id
  }
  zone_mappings {
    vswitch_id = alicloud_vswitch.public-b.id  # Second Public Subnet
    zone_id    = data.alicloud_zones.availability_zones.zones.1.id
  }
}


resource "alicloud_nlb_server_group" "http_server_group" {
  server_group_name = "http-backend-servers"
  server_group_type = "Instance"
  vpc_id            = alicloud_vpc.vpc.id
  scheduler         = "rr"  # Round-robin load distribution
  protocol          = "TCP"
  
  
  health_check {
    health_check_enabled         = true
    health_check_type            = "TCP"
    health_check_connect_port    = 8081  # Check connectivity on port 8081
    healthy_threshold            = 2
    unhealthy_threshold          = 2
    health_check_connect_timeout = 5
    health_check_interval        = 10
  }
}


resource "alicloud_nlb_server_group_server_attachment" "http_server_attachment" {
  count            = length(alicloud_instance.http)  # Number of HTTP servers in the Private Subnet
  server_type      = "Ecs"
  server_id        = alicloud_instance.http[count.index].id
  server_group_id  = alicloud_nlb_server_group.http_server_group.id
  port             = 8081  # Use port 8081 to match the backend service
  weight           = 100
}


resource "alicloud_nlb_listener" "http_listener" {
  listener_protocol      = "TCP"
  listener_port          = 80
  load_balancer_id       = alicloud_nlb_load_balancer.http.id
  server_group_id        = alicloud_nlb_server_group.http_server_group.id
  idle_timeout           = 900
  proxy_protocol_enabled = false
}


output "NLB_URL" {
  value       = alicloud_nlb_load_balancer.http.dns_name
  description = "URL of the Network Load Balancer"
}
