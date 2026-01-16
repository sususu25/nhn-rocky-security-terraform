resource "nhncloud_compute_instance_v2" "rocky" {
  name      = var.instance_name
  region    = var.region
  key_pair  = data.nhncloud_compute_keypair_v2.kp.name
  flavor_id = data.nhncloud_compute_flavor_v2.flavor.id

  # default + 내가 만든 SG 적용 (원하면 default 빼도 됨)
  security_groups = ["default", nhncloud_networking_secgroup_v2.ssh_sg.name]

  network {
    port = nhncloud_networking_port_v2.rocky_port.id
  }

  # 루트 볼륨을 이미지로부터 생성 (문서가 인스턴스 생성 섹션에서 block_device 사용 예시를 보여줌) 
  block_device {
    uuid                  = data.nhncloud_images_image_v2.img.id
    source_type           = "image"
    destination_type      = "volume"
    boot_index            = 0
    volume_size           = 20
    delete_on_termination = true
  }
}
