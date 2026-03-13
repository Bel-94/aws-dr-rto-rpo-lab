resource "aws_security_group" "dr_alb" {
  provider = aws.dr

  name   = "${local.name_prefix}-dr-alb-sg"
  vpc_id = aws_vpc.dr.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "dr_app" {
  provider = aws.dr

  name   = "${local.name_prefix}-dr-app-sg"
  vpc_id = aws_vpc.dr.id

  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.dr_alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "dr_db" {
  provider = aws.dr

  name   = "${local.name_prefix}-dr-db-sg"
  vpc_id = aws_vpc.dr.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.dr_app.id]
  }
}