########################################
# 1) 운영/서비스 엔드포인트 (딱 1개)
# - lb 모드: LB VIP
# - fip 모드: 첫 번째 백엔드의 mgmt FIP (대표 1개만)
########################################
output "service_endpoint" {
  description = "Service endpoint (LB VIP in lb mode, otherwise representative mgmt FIP in fip mode)"
  value       = local.lb_enabled ? nhncloud_lb_loadbalancer_v2.security_lb[0].vip_address : try(nhncloud_networking_floatingip_v2.security_fip[sort(keys(local.backends))[0]].address, null)
}

########################################
# 2) LB VIP (lb 모드에서만)
########################################
output "lb_vip" {
  description = "LB VIP (only in lb mode)"
  value       = local.lb_enabled ? nhncloud_lb_loadbalancer_v2.security_lb[0].vip_address : null
}

########################################
# 3) 백엔드 mgmt Private IPs (SSH용, 사설)
########################################
output "backend_mgmt_private_ips" {
  description = "Backend mgmt port private IPs (one per instance)"
  value       = { for k in sort(keys(local.backends)) : k => nhncloud_networking_port_v2.mgmt_port[k].all_fixed_ips[0] }
}

########################################
# 4) 백엔드 mgmt FIPs (fip 모드에서만, SSH용 공인)
########################################
output "backend_mgmt_fips" {
  description = "Backend mgmt floating IPs (only in fip mode)"
  value       = var.exposure_mode == "fip" ? { for k in sort(keys(local.backends)) : k => nhncloud_networking_floatingip_v2.security_fip[k].address } : {}
}


########################################
# 5) 백엔드 service Private IPs (LB가 물리는 백엔드)
########################################
output "backend_service_private_ips" {
  value = {
    for k, p in nhncloud_networking_port_v2.service_port :
    k => p.all_fixed_ips[0]
  }
}

########################################
# 6) Bastion outputs (lb 모드에서만)
########################################
output "bastion_fip" {
  description = "Bastion floating IP (only in lb mode)"
  value       = local.bastion_enabled ? nhncloud_networking_floatingip_v2.bastion_fip[0].address : null
}

output "bastion_mgmt_private_ip" {
  description = "Bastion mgmt private IP (only in lb mode)"
  value       = local.bastion_enabled ? nhncloud_networking_port_v2.bastion_mgmt_port[0].all_fixed_ips[0] : null
}
