########################################
# Bastion (LB 모드에서만 사용)
########################################

# Bastion 전용 SG: 내 PC에서만 22 허용
resource "nhncloud_networking_secgroup_v2" "bastion_sg" {
  count = local.bastion_enabled ? 1 : 0
  name  = "security-bastion-ssh-sg"
}

resource "nhncloud_networking_secgroup_rule_v2" "bastion_ssh_in" {
  count             = local.bastion_enabled ? 1 : 0
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = var.my_ip_cidr
  security_group_id = nhncloud_networking_secgroup_v2.bastion_sg[0].id

}

resource "nhncloud_networking_secgroup_rule_v2" "bastion_ssh_in_from_jenkins" {
  count = (
    local.bastion_enabled && trimspace(var.jenkins_allowed_cidr) != ""
  ) ? 1 : 0

  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = var.jenkins_allowed_cidr
  security_group_id = nhncloud_networking_secgroup_v2.bastion_sg[0].id
}

# Bastion mgmt 포트
resource "nhncloud_networking_port_v2" "bastion_mgmt_port" {
  count      = local.bastion_enabled ? 1 : 0
  name       = "security-bastion-mgmt-port"
  network_id = var.vpc_id

  dynamic "fixed_ip" {
    for_each = trimspace(var.bastion_mgmt_fixed_ip) != "" ? [1] : []
    content {
      subnet_id  = var.subnet_id
      ip_address = var.bastion_mgmt_fixed_ip
    }
  }

  dynamic "fixed_ip" {
    for_each = trimspace(var.bastion_mgmt_fixed_ip) == "" ? [1] : []
    content {
      subnet_id = var.subnet_id
    }
  }

  security_group_ids = [
    nhncloud_networking_secgroup_v2.bastion_sg[0].id
  ]
}

# Bastion 인스턴스
resource "nhncloud_compute_instance_v2" "bastion" {
  count     = local.bastion_enabled ? 1 : 0
  name      = var.bastion_name
  region    = var.region
  key_pair  = data.nhncloud_compute_keypair_v2.kp.name
  flavor_id = data.nhncloud_compute_flavor_v2.flavor.id

  network {
    port = nhncloud_networking_port_v2.bastion_mgmt_port[0].id
  }

  block_device {
    uuid                  = data.nhncloud_images_image_v2.img.id
    source_type           = "image"
    destination_type      = "volume"
    boot_index            = 0
    volume_size           = 20
    delete_on_termination = true
  }
}

# Bastion Floating IP + 연결
resource "nhncloud_networking_floatingip_v2" "bastion_fip" {
  count = local.bastion_enabled ? 1 : 0
  pool  = "Public Network"
}

resource "nhncloud_networking_floatingip_associate_v2" "bastion_fip_association" {
  count       = local.bastion_enabled ? 1 : 0
  floating_ip = nhncloud_networking_floatingip_v2.bastion_fip[0].address
  port_id     = nhncloud_networking_port_v2.bastion_mgmt_port[0].id
}
