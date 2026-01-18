output "dev_load_balancer_ip" {
  value = module.dev_infra.load_balancer_ip
}

output "prod_load_balancer_ip" {
  value = module.prod_infra.load_balancer_ip
}