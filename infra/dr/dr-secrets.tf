resource "aws_secretsmanager_secret" "dr_db_credentials" {
  provider                = aws.dr
  name                    = "${local.name_prefix}-dr-db-credentials"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "dr_db_credentials" {
  provider  = aws.dr
  secret_id = aws_secretsmanager_secret.dr_db_credentials.id

  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
  })
}
