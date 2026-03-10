#this code creates a CloudWatch log group for our container logs.
resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${local.name_prefix}-app"
  retention_in_days = 7

  tags = {
    Name = "${local.name_prefix}-logs"
  }
}