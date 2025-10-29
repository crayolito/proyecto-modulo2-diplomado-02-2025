output "secret_arn" {
  description = "ARN del secreto"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "parameter_name" {
  description = "Nombre del parámetro SSM"
  value       = aws_ssm_parameter.app_config.name
}
