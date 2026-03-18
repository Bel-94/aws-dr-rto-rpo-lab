module "dr" {
  source = "./dr"

  providers = {
    aws    = aws.dr
    aws.dr = aws.dr
  }

  snapshot_id        = aws_db_snapshot_copy.dr_copy.id
  ecr_image_url      = "${aws_ecr_repository.app.repository_url}:latest"
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  secret_arn         = aws_secretsmanager_secret.db_credentials.arn
  db_name            = var.db_name
  db_username        = var.db_username
  db_password        = random_password.db_password.result
  db_port            = var.db_port
  container_cpu      = var.container_cpu
  container_memory   = var.container_memory
}