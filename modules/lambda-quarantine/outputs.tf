output "function_name" {
  description = "격리 Lambda 함수 이름"
  value       = aws_lambda_function.quarantine.function_name
}

output "function_arn" {
  description = "격리 Lambda 함수 ARN"
  value       = aws_lambda_function.quarantine.arn
}

output "role_arn" {
  description = "격리 Lambda IAM 역할 ARN"
  value       = aws_iam_role.quarantine_lambda.arn
}
