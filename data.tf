# VPC 조회 (문서 예시 그대로: region/tenant_id/id/name 지정) 
data "nhncloud_networking_vpc_v2" "target_vpc" {
  region    = var.region
  tenant_id = var.tenant_id
  id        = var.vpc_id
  name      = var.vpc_name
}

# 서브넷 조회 
data "nhncloud_networking_vpcsubnet_v2" "target_subnet" {
  region    = var.region
  tenant_id = var.tenant_id
  id        = var.subnet_id
  #name      = var.subnet_name
  #shared    = var.subnet_shared

  lifecycle {
    postcondition {
      condition     = var.subnet_name == "" || self.name == var.subnet_name
      error_message = "subnet_id는 맞지만 subnet_name이 기대값과 다릅니다. 콘솔의 서브넷 이름을 다시 확인하세요."
    }

    postcondition {
      condition     = self.shared == var.subnet_shared
      error_message = "subnet_id는 맞지만 shared 값이 기대값과 다릅니다. subnet_shared 값을 다시 확인하세요."
    }
  }
}
# 키페어 조회
data "nhncloud_compute_keypair_v2" "kp" {
  name = var.keypair_name
}

# 인스턴스 타입(Flavor) 조회
data "nhncloud_compute_flavor_v2" "flavor" {
  name = var.flavor_name
}

# 이미지 조회(이름으로) 
data "nhncloud_images_image_v2" "img" {
  name = var.image_name
}
