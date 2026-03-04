# Kubernetes Cluster on macOS (Multipass + Terraform)
이 레포지토리에서는 macOS(M1) 환경에서 Multipass, Terraform을 이용하여 다음과 같은 Kubernetes 클러스터 환경을 구축합니다.

## 사전 설치 사항
- Terraform v1.11.3 이상 : [Terraform 설치 링크](https://developer.hashicorp.com/terraform/install)
- multipass v1.15.1 : [multipass 설치 링크](https://canonical.com/multipass)

## 구성 요소
| 구성 요소 | 수량 | 설명 |
| --- | --- | --- |
| Control Plane Node | 1 | 클러스터 제어 |
| Worker Node | 2 | 서비스 워크로드 처리 |
| Cilium | ✅ | Pod 간 통신을 위한 CNI 플러그인 |
| Terraform | ✅ | 인프라 정의 및 상태 관리 | 
| Multipass | ✅ | 로컬 VM 기반 클러스터 실행 |

## 구조
```
.
├── init
│   └── k8s.yaml
├── shell
│   ├── cluster-init.sh
│   ├── delete-vm.sh
│   └── join-all.sh
├── main.tf
├── variables.tf
├── versions.tf
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
rm -rf .terraform .terraform.lock.hcl terraform.tfstate* kubeconfig
```