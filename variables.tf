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
  default = "SSH 허용 CIDR (예: 203.0.113.10/32). 보안상 0.0.0.0/0는 권장하지 않음."
}
