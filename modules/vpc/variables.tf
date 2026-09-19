variable "vpc_name" {
    description = "VPC 이름"
    type = string
    default = "WHS_VPC"
}

variable "vpc_cidr" {
    description = "VPC CIDR 블럭"
    type = string
    default = "10.3.0.0/16"
}

variable "availability_zones" {
    description = "가용 영역"
    type = list(string)
    default = ["ap-northeast-2a", "ap-northeast-2b"]
}

variable "public_subnet_cidrs" {
    description = "Public 서브넷 CIDR"
    type = list(string)
    default = ["10.3.1.0/24", "10.3.2.0/24"]
}

variable "private_subnet_cidrs" {
    description = "Private 서브넷 CIDR"
    type = list(string)
    default = ["10.3.11.0/24", "10.3.12.0/24"]
}

variable "quarantine_nacl_rule_inbound" {
  description = "격리 placeholder 인바운드 NACL 규칙 번호 (기존 규칙 번호와 충돌하지 않는 값으로 설정)"
  type        = number
  default     = 1
}

variable "quarantine_nacl_rule_outbound" {
  description = "격리 placeholder 아웃바운드 NACL 규칙 번호 (기존 규칙 번호와 충돌하지 않는 값으로 설정)"
  type        = number
  default     = 1
}

variable "quarantine_nacl_placeholder_cidr" {
  description = "격리 NACL placeholder CIDR (실제 트래픽과 매치되지 않는 값, 격리 시 인스턴스 IP로 교체됨)"
  type        = string
  default     = "203.0.113.0/32"
}