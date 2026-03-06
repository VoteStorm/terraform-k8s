# Kubernetes Cluster on GCP
이 레포지토리에서는 GCP 환경에서 Terraform을 이용하여 다음과 같은 Kubernetes 클러스터 환경을 구축합니다.

## 사전 설치 사항
- Terraform v1.11.3 이상 : [Terraform 설치 링크](https://developer.hashicorp.com/terraform/install)

## 구성 요소
| 구성 요소 | 수량 | 설명 |
| --- | --- | --- |
| Control Plane Node | 1 | 클러스터 제어 |
| Worker Node | 3 | 서비스 워크로드 처리 |
| Terraform | ✅ | 인프라 정의 및 상태 관리 | 

## 구조
```
.
├── compute.tf
├── network.tf
├── csi.tf
├── output.tf
├── provider.tf
├── variables.tf
├── versions.tf
├── terraform.tfvars.example
└── README.md
```

## 설치 방법
1. Terraform 초기화 및 배포
```bash
terraform init
terraform apply -auto-approve
```

2. 삭제
```bash
terraform destroy -auto-approve
```