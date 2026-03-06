# ADR-002: Cilium IPAM 모드로 cluster-pool 선택

## 상태
Accepted

## 컨텍스트
<!-- 이 결정이 필요한 배경과 관련된 정보를 서술합니다.
현재 시스템 구조나 기술 상황, 외부 제약 조건 등을 기술합니다. -->
CNI로 Cilium을 택한 후, Cilium에서의 IPAM 모드를 결정해야 한다. IPAM이란 IP Address Management의 약자로, 클러스터 내에서 IP 주소를 어떻게 할당하고 관리할지를 결정하는 중요한 요소이다. Cilium은 여러 IPAM 모드를 지원하며, 온프레미스 환경에서는 `cluster-pool`과 kubernetes` 모드가 주로 고려된다. `cluster-pool` 모드는 클러스터 전체에서 사용할 IP 주소 풀을 미리 정의하여 관리하는 방식이며, kubernetes 모드는 Kubernetes의 네이티브 IPAM 기능을 활용하여 각 노드에서 IP 주소를 할당하는 방식이다.

## 결정
<!-- 어떤 결정을 내렸는지를 명확하게 서술합니다.
선택한 아키텍처나 도구, 패턴, 구조 등과 그 이유를 기술합니다. -->
Cilium IPAM 모드로 `cluster-pool`을 선택한다.

## 근거
<!-- 왜 이 결정을 내렸는지 설명합니다.
다른 대안들과 비교한 장단점, 주요 고려 요소 등을 포함합니다. -->
1. **관리 중앙화**
    `cluster-pool` 모드는 클러스터 전체에서 사용할 IP 주소 풀을 중앙에서 관리할 수 있어, IP 주소 할당과 관리를 일원화할 수 있다. 또한 트러블슈팅 시에도 IP 주소 할당 문제를 중앙에서 쉽게 파악할 수 있다.
2. **Cilium 선택 의사결정의 일관성**
    CNI로 Cilium을 선택한 이유는 네트워크 제어를 Cilium 단일 주체에게 위임하기 위함이었다. `kubernetes` 모드는 Pod IP 할당을 Kubernetes controller-manager가 담당하므로 제어 주체가 둘로 나뉜다. `cluster-pool`은 Cilium이 IP 할당까지 전담하여 ADR-001의 결정과 일관된다.
3. **CRD 기반 IP 풀 관리**
    `cluster-pool` 모드는 Cilium의 CRD를 통해 IP 풀을 정의하고 관리할 수 있어, Kubernetes 네이티브 방식으로 IP 풀을 선언적으로 관리할 수 있다. `kubernetes` 모드에서 NodeCIDR 변경 시 kubeadm 재설정이 필요한 것과 달리 IP 풀 변경을 CRD 업데이트로 간편하게 처리할 수 있다.

## 결과
- `kubeadm init` 시 `--pod-network-cidr` 옵션을 사용하지 않는다.
- Cilium 설치 시 `ipam.mode=cluster-pool`을 명시한다.
- Pod IP 대역과 노드별 서브넷을 지정한다.

## 대안
- **kubernetes 모드**: Kubernetes 자체에서 노드별 서브넷을 할당하고 Cilium이 그 범위 안에서 Pod에 IP를 배분하는 방식이다. 네트워크 제어 주체가 둘로 나뉘어 Cilium 선택 이유와 일관성이 없어 선택하지 않았다.

## 작성일자
2026-03-03
