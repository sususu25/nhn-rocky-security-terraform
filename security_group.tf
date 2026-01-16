# SG 생성 :contentReference[oaicite:6]{index=6}
resource "nhncloud_networking_secgroup_v2" "ssh_sg" {
  name = "tf-ssh-sg"
}

# SSH(22) 인바운드
resource "nhncloud_networking_secgroup_rule_v2" "ssh_in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = var.my_ip_cidr
  security_group_id = nhncloud_networking_secgroup_v2.ssh_sg.id
}
