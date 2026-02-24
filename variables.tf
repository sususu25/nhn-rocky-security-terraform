variable "region" {
  type = string
}

variable "auth_url" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "user_name" {
  type = string
}

variable "password" {
  type      = string
  sensitive = true
}

# 기존 VPC/서브넷 조회용 (콘솔에서 값 복붙)
variable "vpc_id" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "subnet_name" {
  type = string
}

variable "subnet_shared" {
  type    = bool
  default = true
}

# 인스턴스 생성에 필요한 값들
variable "instance_name" {
  type    = string
  default = "tf-rocky-01"
}

variable "keypair_name" {
  type = string
}

variable "flavor_name" {
  type = string
}

variable "image_name" {
  type = string
}

# SG 룰에서 사용할 내 IP 대역 (SSH 제한용) - 접속 PC의 공인 IP 확인 후 /32 형식으로 입력
variable "my_ip_cidr" {
  type        = string
  description = "Your public IP in CIDR (e.g., 203.0.113.10/32). Used to allow SSH to bastion."
  # default = null  (아예 default 제거)

  validation {
    condition     = can(regex("^\\d+\\.\\d+\\.\\d+\\.\\d+\\/\\d+$", var.my_ip_cidr))
    error_message = "my_ip_cidr must be in CIDR format like 203.0.113.10/32"
  }
}

# Floating IP 설정
variable "create_floating_ip" {
  type        = bool
  default     = true
  description = "Floating IP 생성 여부"
}

variable "floating_ip_pool" {
  type        = string
  default     = "public"
  description = "Floating IP를 할당받을 네트워크 풀"
}

# 어떤 외부 노출 방식을 쓸지
variable "exposure_mode" {
  type        = string
  description = "fip(SSH용 FIP) 또는 lb(서비스용 LB VIP)"
  default     = "fip"

  validation {
    condition     = contains(["fip", "lb"], var.exposure_mode)
    error_message = "exposure_mode는 fip 또는 lb만 가능합니다."
  }
}

# 서비스용(내부) 서브넷: LB/VIP가 붙는 쪽
variable "service_subnet_id" {
  type        = string
  description = "서비스 트래픽(예: 80/443)이 흐르는 서브넷 ID. 비워두면 subnet_id를 재사용."
  default     = ""
}

# 서비스 포트 (LB가 멤버로 전달할 포트)
variable "service_target_port" {
  type        = number
  description = "LB가 백엔드(인스턴스)로 전달할 포트"
  default     = 80
}

# LB VIP 고정 (옵션)
variable "lb_vip_address" {
  type        = string
  description = "LB VIP를 고정 IP로 지정(옵션). 빈 값이면 자동 할당."
  default     = ""
}

variable "mgmt_fixed_ips" {
  type        = list(string)
  description = "Fixed private IPs for mgmt ports (same order as backends). If empty, auto-assign."
  default     = []
}

variable "rocky_count" {
  type        = number
  description = "Number of Rocky backend instances (1~30)"
  default     = 3

  validation {
    condition     = var.rocky_count >= 1 && var.rocky_count <= 30
    error_message = "rocky_count must be between 1 and 30."
  }
}

########################################
# Bastion (LB 모드에서 SSH 진입점)
########################################
variable "bastion_enabled" {
  type        = bool
  description = "LB 모드에서 Bastion(점프 서버) 생성 여부"
  default     = true
}

variable "bastion_name" {
  type        = string
  description = "Bastion 인스턴스 이름"
  default     = "security-bastion"
}

variable "bastion_mgmt_fixed_ip" {
  type        = string
  description = "Bastion mgmt 포트 사설 IP 고정(옵션). 빈 값이면 자동 할당."
  default     = ""
}

########################################
# HA VIP (allowed_address_pairs)
########################################
variable "ha_vip_enabled" {
  type        = bool
  description = "HA 구성 시, 포트에 VIP를 허용(allowed_address_pairs)할지 여부"
  default     = false
}

variable "ha_vip_address" {
  type        = string
  description = "HA에서 사용할 VIP(사설). ha_vip_enabled=true 일 때만 사용."
  default     = ""
}

variable "mgmt_subnet_id" {
  type        = string
  description = "Subnet ID for management NIC"
  default     = ""
}



