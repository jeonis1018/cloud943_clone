# VPC
output "vpc_id" {
    description = "생성된 VPC의 ID"
    value = aws_vpc.this.id
}

output "vpc_cidr" {
    description = "VPC CIDR 블럭"
    value = aws_vpc.this.cidr_block
}

# Public Subnet
output "public_subnet_ids" {
    description = "Public 서브넷 ID"
    value = aws_subnet.public[*].id
}

# Private Subnet
output "private_subnet_ids" {
    description = "Private 서브넷 ID 목록"
    value = aws_subnet.private[*].id
}

# Routing Table
output "public_route_table_id" {
    description = "Public 라우팅 테이블 ID"
    value = aws_route_table.public.id
}

output "private_route_table_ids" {
    description = "Private 라우팅 테이블 ID"
    value = aws_route_table.private[*].id
}

# Internet Gateway
output "igw_id" {
    description = "인터넷 게이트웨이 ID"
    value = aws_internet_gateway.this.id
}

# EIP
output "nat_eip_ids" {
  description = "NAT Gateway에 연결된 Elastic IP ID"
  value = aws_eip.nat[*].id
}

# NAT Gateway
output "nat_gateway_ids" {
  description = "NAT Gateway ID"
  value = aws_nat_gateway.this[*].id
}

# Quarantine NACL
output "quarantine_nacl_id" {
  description = "Private 서브넷 NACL ID"
  value       = tolist(data.aws_network_acls.private.ids)[0]
}

output "quarantine_nacl_rule_inbound" {
  description = "격리 placeholder 인바운드 규칙 번호"
  value       = var.quarantine_nacl_rule_inbound
}

output "quarantine_nacl_rule_outbound" {
  description = "격리 placeholder 아웃바운드 규칙 번호"
  value       = var.quarantine_nacl_rule_outbound
}
