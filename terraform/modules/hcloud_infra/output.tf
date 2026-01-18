output "load_balancer_ip" {
  value = hcloud_load_balancer.lb.ipv4
}

output "api_ips" {
  value = hcloud_server.apis[*].ipv4_address
}

output "db_ip" {
  value = hcloud_server.db.ipv4_address
}