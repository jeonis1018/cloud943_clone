output "instance_ids" {
  description = "IDs of the private EC2 web application instances."
  value       = aws_instance.web[*].id
}

output "instance_private_ips" {
  description = "Private IP addresses of the EC2 web application instances."
  value       = aws_instance.web[*].private_ip
}

output "quarantine_sg_id" {
  description = "격리용 보안 그룹 ID (인바운드/아웃바운드 규칙 없음)"
  value       = aws_security_group.quarantine.id
}
