resource "aws_ecs_cluster" "dr" {
  provider = aws.dr

  name = "${local.name_prefix}-dr-cluster"
}

resource "aws_ecs_service" "dr_service" {
  provider = aws.dr

  name            = "${local.name_prefix}-dr-service"
  cluster         = aws_ecs_cluster.dr.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = aws_subnet.dr_private_app[*].id
    security_groups = [aws_security_group.dr_app.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.dr.arn
    container_name   = "app"
    container_port   = var.app_port
  }
}