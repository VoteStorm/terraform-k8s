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
on-prem
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

# Add-ons 설치 가이드
이 프로젝트는 로컬 Mac 환경의 Kubernetes 클러스터에 다양한 Add-on(Observability, GitOps 등)을 설치하고 설정하기 위한 자동화된 스크립트를 제공합니다. 모든 Add-on은 Helm Chart와 `values/` 디렉토리에 정의된 설정 파일 기반으로 설치됩니다. Observability는 현재 ArgoCD로 배포되고 있으며, 해당 파일은 따로 관리되고 있습니다. [ArgoCD ApplicationSet](https://github.com/VoteStorm/chaoslab-gitops/tree/feature/on-prem/%234-argocd-addon)

## 구조
```
addon/
├── install.sh               # 전체 Add-on을 순차 설치하는 스크립트
├── verify.sh                # Add-on 설치 여부 및 접근성 확인 스크립트
├── hosts.generated          # xxx.chaos-lab.local 도메인용 hosts 매핑 파일
├── scripts/                 # 개별 Add-on을 설치하는 스크립트
└── values/                  # Helm values.yaml 모음
    ├── argocd/
    ├── ingress-nginx/
    └── metallb/
```

## 설치 방법
### 1. 사전 조건
- Kubernetes 클러스터가 로컬에서 실행 중이어야 함
- `xxx.chaos-lab.local` 도메인에 대한 hosts 매핑 필요 (`/etc/hosts`)

## 2. Add-on 일괄 설치
```bash
cd on-prem/addons
./install.sh
```

> MetalLB -> Ingress-Nginx -> Storageclass -> ArgoCD -> Monitoring(GitOps) 순으로 설치됩니다 \
> 설치 후 host 파일을 추가해야 `xxx.chaos-lab.local` 형태의 로컬 도메인으로 각 서비스에 접속할 수 있습니다.

### 3. 설치 검증
```bash
./verify.sh
```
서비스별 도메인 응답 여부, Pod 상태, ArgoCD Sync 상태 등을 자동 확인합니다.

## 포함된 Add-on 목록
| Add-on | 설명 |
| --- | --- |
| MetalLB | 로컬 환경에서 LoadBalancer 형태 지원을 위한 IP 제공 |
| Ingress-Nginx | HTTP/HTTPS 트래픽 라우팅을 위한 Ingress Controller |
| Local Path Provisioner | 로컬 디스크를 활용한 StorageClass 제공 |
| ArgoCD | GitOps 기반 애플리케이션 배포 관리 |
| Prometheus-Grafana | 모니터링 대시보드 및 메트릭 수집 |
| Loki-Promtail | 로그 수집 및 검색 |

## 로컬 도메인 설정
`install.sh` 실행 시 자동 생성되는 `hosts.generated` 파일을 `/etc/hosts`에 반영해야 각 서비스에 브라우저 접속이 가능합니다.
```bash
sudo bash -c 'cat $HOSTS_FILE >> /etc/hosts'
```
