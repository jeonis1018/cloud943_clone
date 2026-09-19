variable "quarantine_sg_id" {
  description = "격리용 보안 그룹 ID (module.ec2.quarantine_sg_id)"
  type        = string
}

variable "nacl_id" {
  description = "Private 서브넷 NACL ID (module.vpc.quarantine_nacl_id)"
  type        = string
}

variable "nacl_rule_inbound" {
  description = "격리 placeholder 인바운드 NACL 규칙 번호 (module.vpc.quarantine_nacl_rule_inbound)"
  type        = number
}

variable "nacl_rule_outbound" {
  description = "격리 placeholder 아웃바운드 NACL 규칙 번호 (module.vpc.quarantine_nacl_rule_outbound)"
  type        = number
}

variable "lambda_source_path" {
  description = "Lambda 핸들러 파일 경로"
  type        = string
}
