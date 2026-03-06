
variable "multipass_image" {
  description = "Multipass에서 사용할 Ubuntu 이미지 버전"
  type        = string
  default     = "22.04"
}

variable "masters" {
  description = "Control Plane 노드 수"
  type        = number
  default     = 1
}

variable "workers" {
  description = "Worker 노드 수"
  type        = number
  default     = 2
}

variable "masters_cpu" {
  description = "Control Plane 노드에 할당할 CPU 수"
  type        = number
  default     = 2
}

variable "masters_memory" {
  description = "Control Plane 노드에 할당할 메모리 크기 (GB)"
  type        = number
  default     = 4
}

variable "masters_disk" {
  description = "Control Plane 노드에 할당할 디스크 크기 (GB)"
  type        = number
  default     = 10
}

variable "workers_cpu" {
  description = "Worker 노드에 할당할 CPU 수"
  type        = number
  default     = 2
}

variable "workers_memory" {
  description = "Worker 노드에 할당할 메모리 크기 (GB)"
  type        = number
  default     = 4
}

variable "workers_disk" {
  description = "Worker 노드에 할당할 디스크 크기 (GB)"
  type        = number
  default     = 10
}