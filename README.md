# NHN Cloud Terraform: Existing VPC/Subnet 기반 인스턴스 프로비저닝

## 개요
본 프로젝트는 NHN Cloud 환경에서 기존에 구축된 VPC 및 Subnet을 참조하여,
동일한 인스턴스 구성을 Terraform(IaC)으로 자동 생성·관리하기 위한 예제입니다.
인프라 구성을 코드로 표준화함으로써 환경 간 구성 편차를 제거하고,
변경 이력을 코드로 관리하여 운영 효율성과 재현성을 확보하는 것을 목표로 합니다.

## 생성 리소스 (Terraform이 생성)
- Security Group 
    - ssh_sg(22)
    - service_sg(80)
- Backend Instance N개
    - mgmt_port: SSH/Ansible 관리용 NIC
    - service_port: 서비스 트래픽(LB 백엔드) NIC
### exposure_mode = "lb" 일 때 추가
- Bastion 인스턴스 1대 + Bastion FIP 1개
- Load Balancer 구성
    - Loadbalancer(VIP) + Listener + Pool + Health Monitor + Members(N개)
### exposure_mode = "fip" 일 때 추가
- 백엔드 mgmt 포트에 FIP N개 (서버별 1개)

## 전제 조건 (기존에 존재해야 하며 Terraform이 조회)
- VPC: `vpc_id`
- Subnet: `subnet_id`, `mgmt_subnet_id', 'service_subnet_id'
- Keypair: `keypair_name`
- Image / Flavor: `image_name`, `flavor_name`

## 사용자가 반드시 설정해야 하는 값
- Provider: `region`, `auth_url`, `tenant_id`, `user_name`, `password`
- Network: `vpc_id`, `vpc_name`, `subnet_id`, `subnet_shared`
- Instance: `keypair_name`, `flavor_name`, `image_name`, `backend_count`, `exposure_mode` *(`lb` 또는 `fip`)*
- Security: `my_ip_cidr` (예: `203.0.113.10/32`)

- (LB 모드 사용 시)
  - `bastion_enabled` *(권장: `true` — LB 모드에서 SSH/Ansible 진입점 필요)*

- (선택) 서브넷 분리/고정 IP를 사용할 때만
  - `mgmt_subnet_id` *(관리 NIC용 서브넷 / 미지정 시 `subnet_id` 사용)*
  - `service_subnet_id` *(서비스 NIC/LB용 서브넷 / 미지정 시 `subnet_id` 사용)*
  - `backend_service_fixed_ips` *(서비스 NIC 고정 IP 리스트 — `service_subnet_id` CIDR 대역과 일치해야 함)*
  - `lb_vip_address` *(LB VIP 고정 — `service_subnet_id` CIDR 대역과 일치해야 함)*

## 보안 주의사항
다음 파일은 민감 정보를 포함할 수 있으므로 Git에 커밋해서는 안 됩니다.
- `terraform.tfvars`
- `terraform.tfstate`, `terraform.tfstate.backup`
- `.terraform/`

비밀번호(`password`)는 파일에 저장하지 않고 환경변수로 주입하는 방식을 권장합니다.
- PowerShell: `$env:TF_VAR_password="NHN_CLOUD_API_PASSWORD"`
- bash: `export TF_VAR_password="NHN_CLOUD_API_PASSWORD"`

## Terraform 실행 명령어
- `terraform fmt -recursive`
- `terraform validate`
- `terraform init`
- `terraform plan`
- `terraform apply`

## 리소스 삭제
- `terraform destroy`

### Outputs (terraform output)

- Endpoint
  - `service_endpoint`
    - `lb` 모드: LB VIP(서비스 고정 주소)
    - `fip` 모드: 대표 FIP(접근용 엔드포인트)

- Load Balancer (`lb` 모드일 때만)
  - `lb_vip` *(LB VIP 주소)*
  - `service_endpoint` *(= `lb_vip`)*
  
- Bastion (`lb` 모드 + `bastion_enabled=true`일 때만)
  - `bastion_fip` *(Bastion 공인 IP — SSH/Ansible 진입점)*

- Backend IPs (다중 서버 기준)
  - `backend_mgmt_private_ips` *(맵: 백엔드별 mgmt 사설 IP)*
  - `backend_service_private_ips` *(맵: 백엔드별 service 사설 IP)*

- Floating IPs (`fip` 모드일 때만)
  - `backend_mgmt_fips` *(맵: 백엔드별 mgmt 공인 IP)*

---

# NHN Cloud Terraform: Instance Provisioning on Existing VPC/Subnet

## Overview
This project is a Terraform (IaC) example that **provisions and manages a consistent set of instances** on NHN Cloud by **referencing existing VPCs and Subnets**.
By standardizing infrastructure as code, it minimizes configuration drift across environments and improves operational efficiency and reproducibility by tracking changes in version control.

---

## Resources Created (Provisioned by Terraform)
- Security Groups
  - `ssh_sg` (22)
  - `service_sg` (80)
- Backend Instances (N)
  - `mgmt_port`: management NIC for SSH/Ansible
  - `service_port`: service NIC for application traffic (LB backend)

### Additional resources when `exposure_mode = "lb"`
- Bastion instance (1) + Bastion Floating IP (1)
- Load Balancer
  - Load Balancer (VIP) + Listener + Pool + Health Monitor + Members (N)

### Additional resources when `exposure_mode = "fip"`
- Floating IPs on backend `mgmt_port` (N, one per server)

---

## Prerequisites (Must Exist and Will Be Looked Up by Terraform)
- VPC: `vpc_id`
- Subnets: `subnet_id`, `mgmt_subnet_id`, `service_subnet_id`
- Keypair: `keypair_name`
- Image / Flavor: `image_name`, `flavor_name`

---

## Required User Configuration
- Provider: `region`, `auth_url`, `tenant_id`, `user_name`, `password`
- Network: `vpc_id`, `vpc_name`, `subnet_id`, `subnet_shared`
- Instance: `keypair_name`, `flavor_name`, `image_name`, `backend_count`, `exposure_mode` *(`lb` or `fip`)*
- Security: `my_ip_cidr` (e.g., `203.0.113.10/32`)

### (When using LB mode)
- `bastion_enabled` *(recommended: `true` — required as an SSH/Ansible entry point in LB mode)*

### (Optional) Only when using subnet separation / fixed IPs
- `mgmt_subnet_id` *(subnet for management NIC; falls back to `subnet_id` if not set)*
- `service_subnet_id` *(subnet for service NIC/LB; falls back to `subnet_id` if not set)*
- `backend_service_fixed_ips` *(list of fixed IPs for service NIC; must match the CIDR of `service_subnet_id`)*
- `lb_vip_address` *(fixed LB VIP; must match the CIDR of `service_subnet_id`)*

---

## Security Notes
The following files may contain sensitive information and **must not be committed to Git**:
- `terraform.tfvars`
- `terraform.tfstate`, `terraform.tfstate.backup`
- `.terraform/`

It is recommended to inject `password` via environment variables instead of storing it in files:
- PowerShell: `$env:TF_VAR_password="NHN_CLOUD_API_PASSWORD"`
- bash: `export TF_VAR_password="NHN_CLOUD_API_PASSWORD"`

---

## Terraform Commands
- `terraform fmt -recursive`
- `terraform validate`
- `terraform init`
- `terraform plan`
- `terraform apply`

---

## Destroy Resources
- `terraform destroy`

---

## Outputs (`terraform output`)
- Endpoint
  - `service_endpoint`
    - `lb` mode: LB VIP (fixed service address)
    - `fip` mode: a representative FIP (access endpoint)

- Load Balancer (only in `lb` mode)
  - `lb_vip` *(LB VIP address)*
  - `service_endpoint` *(= `lb_vip`)*

- Bastion (only in `lb` mode with `bastion_enabled=true`)
  - `bastion_fip` *(public IP for Bastion — SSH/Ansible entry point)*

- Backend IPs (multi-instance)
  - `backend_mgmt_private_ips` *(map: mgmt private IP per backend)*
  - `backend_service_private_ips` *(map: service private IP per backend)*

- Floating IPs (only in `fip` mode)
  - `backend_mgmt_fips` *(map: mgmt public IP per backend)*

