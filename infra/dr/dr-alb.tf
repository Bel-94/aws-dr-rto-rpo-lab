resource "aws_lb" "dr" {
  provider = aws.dr

  name               = "${local.name_prefix}-dr-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.dr_alb.id]
  subnets            = aws_subnet.dr_public[*].id
}

resource "aws_lb_target_group" "dr" {
  provider = aws.dr

  name        = "${local.name_prefix}-dr-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.dr.id
  target_type = "ip"
}

resource "aws_lb_listener" "dr_http" {
  provider = aws.dr

  load_balancer_arn = aws_lb.dr.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dr.arn
  }
}