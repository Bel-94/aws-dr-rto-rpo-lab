resource "aws_cloudwatch_log_group" "dr_app" {
  provider = aws.dr

  name              = "/ecs/${local.name_prefix}-dr-app"
  retention_in_days = 7
}