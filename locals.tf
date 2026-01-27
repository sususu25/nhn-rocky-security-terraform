locals {
  mgmt_subnet_id    = var.mgmt_subnet_id != "" ? var.mgmt_subnet_id : var.subnet_id
  service_subnet_id = var.service_subnet_id != "" ? var.service_subnet_id : var.subnet_id
  lb_enabled        = var.exposure_mode == "lb"
  bastion_enabled   = var.exposure_mode == "lb" && var.bastion_enabled

  backend_keys = [for i in range(var.backend_count) : format("rocky-%02d", i + 1)]

  backends = {
    for i, k in local.backend_keys :
    k => {
      index = i
      name  = k

      service_fixed_ip = (
        contains(keys(var.backend_service_fixed_ips), k) &&
        trimspace(var.backend_service_fixed_ips[k]) != ""
      ) ? trimspace(var.backend_service_fixed_ips[k]) : null
    }
  }

  # ✅ 출력용 endpoint: LB면 LB VIP, 아니면 FIP(있으면) 반환
  service_endpoint = (
    local.lb_enabled
    ? nhncloud_lb_loadbalancer_v2.security_lb[0].vip_address
    : try(nhncloud_networking_floatingip_v2.security_fip[sort(keys(local.backends))[0]].address, null)
  )
}
