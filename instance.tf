resource "nhncloud_compute_instance_v2" "rocky" {
  for_each  = local.backends
  name      = "security-${each.key}"
  region    = var.region
  key_pair  = data.nhncloud_compute_keypair_v2.kp.name
  flavor_id = data.nhncloud_compute_flavor_v2.flavor.id

  # ✅ mgmt 포트(인스턴스별 1개)
  network {
    port = nhncloud_networking_port_v2.mgmt_port[each.key].id
  }

  # ✅ service 포트(인스턴스별 1개)
  network {
    port = nhncloud_networking_port_v2.service_port[each.key].id
  }

  # ✅ 루트 볼륨
  block_device {
    uuid                  = data.nhncloud_images_image_v2.img.id
    source_type           = "image"
    destination_type      = "volume"
    boot_index            = 0
    volume_size           = 20
    delete_on_termination = true
  }
}
