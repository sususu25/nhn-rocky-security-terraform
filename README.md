# NHN Cloud Terraform: Existing VPC/Subnet 기반 인스턴스 프로비저닝

## 개요
본 프로젝트는 NHN Cloud 환경에서 기존에 구축된 VPC 및 Subnet을 참조하여,
동일한 인스턴스 구성을 Terraform(IaC)으로 자동 생성·관리하기 위한 예제입니다.
인프라 구성을 코드로 표준화함으로써 환경 간 구성 편차를 제거하고,
변경 이력을 코드로 관리하여 운영 효율성과 재현성을 확보하는 것을 목표로 합니다.

## 생성 리소스 (Terraform이 생성)
- Security Group 1개
- SSH(22/tcp) Ingress Rule 1개 (지정 CIDR만 허용)
- Compute Instance 1대 (이미지 기반 루트 볼륨 생성)

## 전제 조건 (기존에 존재해야 하며 Terraform이 조회)
- VPC: `vpc_id`, `vpc_name`
- Subnet: `subnet_id`, `subnet_shared` (true/false)
- Keypair: `keypair_name`
- Image / Flavor: `image_name`, `flavor_name`

## 사용자가 반드시 설정해야 하는 값
- Provider: `region`, `auth_url`, `tenant_id`, `user_name`, `password`
- Network: `vpc_id`, `vpc_name`, `subnet_id`, `subnet_shared`
- Instance: `keypair_name`, `flavor_name`, `image_name`, `instance_name` (선택)
- Security: `my_ip_cidr` (예: `203.0.113.10/32`)

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

---

# NHN Cloud Terraform: Instance Provisioning on an Existing VPC/Subnet

## Overview
This project is a Terraform (IaC) example for provisioning a consistent compute instance
on NHN Cloud by referencing pre-existing VPC and Subnet resources.
By defining infrastructure as code, it enables standardized provisioning,
clear change tracking, and improved operational efficiency.

## Resources Created (by Terraform)
- One Security Group
- One SSH (22/tcp) ingress rule (restricted to a specified CIDR)
- One Compute instance (root volume created from an image)

## Prerequisites (Must already exist and are looked up by Terraform)
- VPC: `vpc_id`, `vpc_name`
- Subnet: `subnet_id`, `subnet_shared` (true/false)
- Keypair: `keypair_name`
- Image / Flavor: `image_name`, `flavor_name`

## Required Configuration
- Provider: `region`, `auth_url`, `tenant_id`, `user_name`, `password`
- Network: `vpc_id`, `vpc_name`, `subnet_id`, `subnet_shared`
- Instance: `keypair_name`, `flavor_name`, `image_name`, `instance_name` (optional)
- Security: `my_ip_cidr` (e.g. `203.0.113.10/32`)

## Security Notes
The following files may contain sensitive information and must NOT be committed to Git:
- `terraform.tfvars`
- `terraform.tfstate`, `terraform.tfstate.backup`
- `.terraform/`

It is recommended to inject sensitive values via environment variables instead of storing them in files.
- PowerShell: `$env:TF_VAR_password="NHN_CLOUD_API_PASSWORD"`
- bash: `export TF_VAR_password="NHN_CLOUD_API_PASSWORD"`

## Terraform Commands
- `terraform fmt -recursive`
- `terraform validate`
- `terraform init`
- `terraform plan`
- `terraform apply`

## Cleanup
- `terraform destroy`
