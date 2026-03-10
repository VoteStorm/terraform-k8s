# terraform-k8s
이 레포지토리는 macOS(M1) 환경과 GCP Cloud 환경에서 Terraform을 이용하여 Kubernetes 클러스터 환경을 자동으로 구축하는 것을 목표로 합니다.

## Contributors
| 담당자 | 담당 역할 |
| --- | --- |
| [Bal1oon](https://github.com/Bal1oon) | On-premise 환경 구축 | 
| [Moses249](https://github.com/Moses249) | GCP 환경 구축 |

## 구성 요소
각 환경은 다음과 같은 공통 구성 요소를 가집니다.
| 구성 요소 | 설명 |
| --- | --- |
| Control Plane Node | 클러스터 제어 |
| Worker Node | 서비스 워크로드 처리 |
| Cilium | Pod 간 통신을 위한 CNI 플러그인 |
| Ingress-Nginx | 인그레스 컨트롤러 |
| Terraform | 인프라 정의 및 상태 관리 | 

환경 별 차이점은 다음과 같습니다.
| 구성 요소 | On-premise 환경 | GCP 환경 |
| --- | --- | --- |
| LoadBalancer | MetalLB | GCP Load Balancing |
| StorageClass | Local Path Provisioner | GCP Persistent Disk CSI |
| Control Plane Topology | Single Control Plane | High Availability Control Plane |

## 상세 정보
각 환경에 대한 상세 정보는 각 디렉토리의 README에 작성되어있습니다.
- [On-premise 환경](https://github.com/VoteStorm/terraform-k8s/tree/main/on-prem)
- [GCP 환경](https://github.com/VoteStorm/terraform-k8s/tree/main/gcp)
