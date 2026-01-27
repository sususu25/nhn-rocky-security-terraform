# SG 생성 :contentReference[oaicite:6]{index=6}
resource "nhncloud_networking_secgroup_v2" "ssh_sg" {
  name = "tf-ssh-sg"
}

# SSH(22) 인바운드
# SSH(22) 인바운드
# - fip 모드: 내 PC(my_ip_cidr)에서 백엔드로 직접 접속 허용
# - lb  모드: 백엔드로의 22는 Bastion에서만 허용 (공인 노출 최소화)
resource "nhncloud_networking_secgroup_rule_v2" "ssh_in" {
  count             = var.exposure_mode == "fip" ? 1 : 0
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = var.my_ip_cidr
  security_group_id = nhncloud_networking_secgroup_v2.ssh_sg.id
}

resource "nhncloud_networking_secgroup_rule_v2" "ssh_from_bastion" {
  count             = local.bastion_enabled ? 1 : 0
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_group_id   = nhncloud_networking_secgroup_v2.bastion_sg[0].id
  security_group_id = nhncloud_networking_secgroup_v2.ssh_sg.id
}

# 서비스용 SG (LB/VIP로 들어오는 서비스 트래픽용)
resource "nhncloud_networking_secgroup_v2" "service_sg" {
  name        = "security-service-sg"
  description = "Service access (from LB/VIP or allowed CIDRs)"
}

# 예시: 일단 80만 열어두기 (원하면 443도 추가)
resource "nhncloud_networking_secgroup_rule_v2" "service_http_in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = nhncloud_networking_secgroup_v2.service_sg.id
}
