
########################################
# (1) 관리용 포트: SSH/FIP 붙는 NIC (인스턴스별 1개)
########################################
resource "nhncloud_networking_port_v2" "mgmt_port" {
  for_each   = local.backends
  name       = "security-mgmt-port-${each.key}"
  network_id = var.vpc_id

  # 고정 IP 주면 사용
  dynamic "fixed_ip" {
    for_each = (
      length(var.mgmt_fixed_ips) > each.value.index &&
      trimspace(var.mgmt_fixed_ips[each.value.index]) != ""
    ) ? [1] : []
    content {
      subnet_id  = var.subnet_id
      ip_address = var.mgmt_fixed_ips[each.value.index]
    }
  }

  # 안 주면 subnet만 지정해서 자동 할당
  dynamic "fixed_ip" {
    for_each = (
      length(var.mgmt_fixed_ips) > each.value.index &&
      trimspace(var.mgmt_fixed_ips[each.value.index]) != ""
    ) ? [] : [1]
    content {
      subnet_id = var.subnet_id
    }
  }

  # HA VIP 허용 (네트워크 레벨)
  dynamic "allowed_address_pairs" {
    for_each = (var.ha_vip_enabled && trimspace(var.ha_vip_address) != "") ? [1] : []
    content {
      ip_address = var.ha_vip_address
    }
  }


  security_group_ids = [
    nhncloud_networking_secgroup_v2.ssh_sg.id
  ]
}


########################################
# (2) 서비스용 포트: LB/VIP가 바라보는 NIC
########################################
resource "nhncloud_networking_port_v2" "service_port" {
  for_each   = local.backends
  name       = "security-service-port-${each.key}"
  network_id = var.vpc_id

  dynamic "fixed_ip" {
    for_each = each.value.service_ip != null ? [1] : []
    content {
      subnet_id  = var.subnet_id
      ip_address = each.value.service_ip
    }
  }

  dynamic "fixed_ip" {
    for_each = each.value.service_ip == null ? [1] : []
    content {
      subnet_id = var.subnet_id
    }
  }

  # HA VIP 허용 (네트워크 레벨)
  dynamic "allowed_address_pairs" {
    for_each = (var.ha_vip_enabled && trimspace(var.ha_vip_address) != "") ? [1] : []
    content {
      ip_address = var.ha_vip_address
    }
  }


  security_group_ids = [
    nhncloud_networking_secgroup_v2.service_sg.id
  ]
}


########################################
# (3) Floating IP는 "fip 모드"에서만 생성/연결 (인스턴스별 1개)
########################################
resource "nhncloud_networking_floatingip_v2" "security_fip" {
  for_each = var.exposure_mode == "fip" ? local.backends : {}
  pool     = "Public Network"
}

resource "nhncloud_networking_floatingip_associate_v2" "security_fip_association" {
  for_each    = var.exposure_mode == "fip" ? local.backends : {}
  floating_ip = nhncloud_networking_floatingip_v2.security_fip[each.key].address
  port_id     = nhncloud_networking_port_v2.mgmt_port[each.key].id
}
