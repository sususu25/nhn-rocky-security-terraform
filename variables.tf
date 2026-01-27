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
  type    = string
  default = "210.120.112.168/32"
  #default = "SSH 허용 CIDR (예: 203.0.113.10/32). 보안상 0.0.0.0/0는 권장하지 않음."
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

variable "backend_count" {
  type        = number
  description = "Number of backend instances"
  default     = 3
}

variable "backend_service_fixed_ips" {
  type        = list(string)
  description = "Fixed private IPs for each backend service port (same order as instances). If empty, auto-assign."
  default     = []
}

