locals {
  service_subnet_id = var.service_subnet_id != "" ? var.service_subnet_id : var.subnet_id
  lb_enabled        = var.exposure_mode == "lb"

  # ✅ 추가: 백엔드 목록(키=rocky-01, rocky-02...) 생성
  backends = {
    for i in range(var.backend_count) :
    format("rocky-%02d", i + 1) => {
      index = i
      service_ip = (
        length(var.backend_service_fixed_ips) > i && trimspace(var.backend_service_fixed_ips[i]) != ""
      ) ? var.backend_service_fixed_ips[i] : null
    }
  }

  # ✅ 출력용 endpoint: LB면 LB VIP, 아니면 FIP(있으면) 반환
  service_endpoint = local.lb_enabled ? nhncloud_lb_loadbalancer_v2.security_lb[0].vip_address : try(nhncloud_networking_floatingip_v2.security_fip[sort(keys(local.backends))[0]].address, null)
}
