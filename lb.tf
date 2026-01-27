
resource "nhncloud_lb_loadbalancer_v2" "security_lb" {
  count         = local.lb_enabled ? 1 : 0
  name          = "security-lb"
  vip_subnet_id = local.service_subnet_id
  vip_address   = var.lb_vip_address != "" ? var.lb_vip_address : null
  security_group_ids = [
    nhncloud_networking_secgroup_v2.service_sg.id
  ]
  admin_state_up = true
}

resource "nhncloud_lb_listener_v2" "security_listener" {
  count           = local.lb_enabled ? 1 : 0
  name            = "security-listener-http"
  protocol        = "HTTP"
  protocol_port   = 80
  loadbalancer_id = nhncloud_lb_loadbalancer_v2.security_lb[0].id
  admin_state_up  = true
}

resource "nhncloud_lb_pool_v2" "security_pool" {
  count          = local.lb_enabled ? 1 : 0
  name           = "security-pool"
  protocol       = "HTTP"
  listener_id    = nhncloud_lb_listener_v2.security_listener[0].id
  lb_method      = "LEAST_CONNECTIONS"
  admin_state_up = true
}

resource "nhncloud_lb_monitor_v2" "security_monitor" {
  count          = local.lb_enabled ? 1 : 0
  name           = "security-monitor"
  pool_id        = nhncloud_lb_pool_v2.security_pool[0].id
  type           = "HTTP"
  delay          = 20
  timeout        = 10
  max_retries    = 5
  url_path       = "/"
  http_method    = "GET"
  expected_codes = "200-399"
  admin_state_up = true
}

resource "nhncloud_lb_member_v2" "security_member" {
  for_each       = local.lb_enabled ? local.backends : {}
  pool_id        = nhncloud_lb_pool_v2.security_pool[0].id
  subnet_id      = local.service_subnet_id
  address        = nhncloud_networking_port_v2.service_port[each.key].all_fixed_ips[0]
  protocol_port  = var.service_target_port
  weight         = 1
  admin_state_up = true
}
