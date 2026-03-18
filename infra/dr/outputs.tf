output "dr_secret_arn" {
  value = aws_secretsmanager_secret.dr_db_credentials.arn
}
