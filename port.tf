# port.tf
resource "nhncloud_networking_port_v2" "rocky_port" {
  name           = "${var.instance_name}-port"
  network_id     = data.nhncloud_networking_vpc_v2.target_vpc.id
  admin_state_up = true

  # 특정 서브넷에 고정 IP 할당(=서브넷 확정)
  fixed_ip {
    subnet_id = data.nhncloud_networking_vpcsubnet_v2.target_subnet.id
  }
}
