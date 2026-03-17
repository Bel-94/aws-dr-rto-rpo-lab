resource "aws_ecs_task_definition" "dr" {
  provider = aws.dr

  family                   = "${local.name_prefix}-dr-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = tostring(var.container_cpu)
  memory                   = tostring(var.container_memory)
  execution_role_arn       = var.execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = var.ecr_image_url
      essential = true

      portMappings = [
        {
          containerPort = var.app_port
          hostPort      = var.app_port
          protocol      = "tcp"
        }
      ]

      environment = [
        { name = "PORT", value = tostring(var.app_port) },
        { name = "DB_HOST", value = aws_db_instance.dr_restore.address },
        { name = "DB_PORT", value = tostring(var.db_port) },
        { name = "DB_NAME", value = var.db_name },
        { name = "DB_USER", value = var.db_username }
      ]

      secrets = [
        {
          name      = "DB_PASSWORD"
          valueFrom = "${var.secret_arn}:password::"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.dr_app.name
          awslogs-region        = "us-west-2"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}
